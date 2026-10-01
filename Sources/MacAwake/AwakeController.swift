import Foundation
import IOKit.pwr_mgt
import Observation
import ServiceManagement

enum AwakeState: Equatable {
    case off
    case on(until: Date?)
}

@MainActor
@Observable
final class AwakeController {
    private(set) var state: AwakeState = .off
    var duration: AwakeDuration = .indefinitely {
        didSet { if isOn { start() } }
    }
    var keepDisplayOn: Bool = UserDefaults.standard.object(forKey: "keepDisplayOn") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(keepDisplayOn, forKey: "keepDisplayOn")
            if isOn { start() }
        }
    }
    private(set) var launchAtLogin = SMAppService.mainApp.status == .enabled

    private var assertionID: IOPMAssertionID = 0
    private var expiryTask: Task<Void, Never>?

    var isOn: Bool { state != .off }

    init() {
        registerLoginItemOnFirstLaunch()
    }

    func setOn(_ on: Bool) {
        on ? start() : stop()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            enabled ? try SMAppService.mainApp.register() : try SMAppService.mainApp.unregister()
        } catch {
            NSLog("MacAwake: login item update failed: \(error)")
        }
        launchAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func start() {
        releaseAssertion()
        let type = keepDisplayOn ? kIOPMAssertionTypePreventUserIdleDisplaySleep : kIOPMAssertionTypePreventUserIdleSystemSleep
        let result = IOPMAssertionCreateWithName(
            type as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "MacAwake is keeping your Mac awake" as CFString,
            &assertionID
        )
        guard result == kIOReturnSuccess else {
            NSLog("MacAwake: IOPMAssertionCreateWithName failed: \(result)")
            state = .off
            return
        }

        let until = duration.interval.map { Date().addingTimeInterval($0) }
        state = .on(until: until)
        expiryTask = until.map { until in
            Task { [weak self] in
                try? await Task.sleep(for: .seconds(until.timeIntervalSinceNow))
                guard !Task.isCancelled else { return }
                self?.stop()
            }
        }
    }

    private func stop() {
        releaseAssertion()
        state = .off
    }

    private func releaseAssertion() {
        expiryTask?.cancel()
        expiryTask = nil
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }
    }

    private func registerLoginItemOnFirstLaunch() {
        let key = "didRegisterLoginItem"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        setLaunchAtLogin(true)
        if launchAtLogin { UserDefaults.standard.set(true, forKey: key) }
    }
}
