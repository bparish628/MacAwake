import SwiftUI

struct MenuPanel: View {
    @Bindable var controller: AwakeController
    @State private var showDurations = true
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Caffeinated").font(.headline)
                    StatusLine(state: controller.state)
                }
                Spacer()
                Toggle("Caffeinated", isOn: Binding(get: { controller.isOn }, set: controller.setOn))
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
            .padding(.vertical, 10)

            Divider()

            DisclosureRow(title: "Duration", expanded: $showDurations, chevron: .down)
            if showDurations {
                DurationPicker(selection: $controller.duration)
                    .padding(.bottom, 10)
            }

            Divider()

            DisclosureRow(title: "Settings", expanded: $showSettings, chevron: .right)
            if showSettings {
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Launch at login", isOn: Binding(get: { controller.launchAtLogin }, set: controller.setLaunchAtLogin))
                    Toggle("Keep display on", isOn: $controller.keepDisplayOn)
                }
                .toggleStyle(.switch)
                .controlSize(.small)
                .padding(.bottom, 10)
            }

            Divider()

            VStack(alignment: .leading, spacing: 0) {
                MenuButton(title: "About") {
                    NSApp.activate()
                    NSApp.orderFrontStandardAboutPanel(nil)
                }
                MenuButton(title: "Quit") { NSApp.terminate(nil) }
            }
            .padding(.vertical, 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(width: 300)
    }
}

private struct StatusLine: View {
    let state: AwakeState

    var body: some View {
        switch state {
        case .off:
            Text("Off").font(.caption).foregroundStyle(.secondary)
        case .on(nil):
            Text("On indefinitely").font(.caption).foregroundStyle(.secondary)
        case .on(let until?):
            Text("Until \(until.formatted(date: .omitted, time: .shortened))")
                .font(.caption).foregroundStyle(.secondary)
        }
    }
}

private struct DisclosureRow: View {
    enum Chevron { case down, right }

    let title: String
    @Binding var expanded: Bool
    let chevron: Chevron

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { expanded.toggle() }
        } label: {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Image(systemName: chevron == .down ? "chevron.down" : "chevron.right")
                    .rotationEffect(rotation)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var rotation: Angle {
        switch chevron {
        case .down: expanded ? .zero : .degrees(-90)
        case .right: expanded ? .degrees(90) : .zero
        }
    }
}

private struct DurationPicker: View {
    @Binding var selection: AwakeDuration

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(AwakeDuration.allCases.enumerated()), id: \.element) { index, duration in
                if index > 0, AwakeDuration.allCases[index - 1].group != duration.group {
                    Circle().fill(.tertiary).frame(width: 3, height: 3)
                }
                Chip(duration: duration, selected: duration == selection) { selection = duration }
            }
        }
        .help("15/30/45 are minutes, 01–12 are hours")
    }
}

private struct Chip: View {
    let duration: AwakeDuration
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(duration.chipLabel)
                .font(.system(size: duration == .indefinitely ? 15 : 12, weight: .semibold).monospacedDigit())
                .frame(width: 28, height: 28)
                .foregroundStyle(selected ? Color.white : Color.primary)
                .background(Circle().fill(selected ? Color.accentColor : Color.primary.opacity(0.08)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(duration.accessibilityLabel)
        .help(duration.accessibilityLabel)
    }
}

private struct MenuButton: View {
    let title: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 5)
                .padding(.horizontal, 6)
                .background(RoundedRectangle(cornerRadius: 5).fill(hovering ? Color.primary.opacity(0.08) : .clear))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, -6)
        .onHover { hovering = $0 }
    }
}
