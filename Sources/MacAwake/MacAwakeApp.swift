import SwiftUI

@main
struct MacAwakeApp: App {
    @State private var controller = AwakeController()

    var body: some Scene {
        MenuBarExtra {
            MenuPanel(controller: controller)
        } label: {
            Image(systemName: controller.isOn ? "cup.and.saucer.fill" : "cup.and.saucer")
        }
        .menuBarExtraStyle(.window)
    }
}
