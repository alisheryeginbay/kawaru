import SwiftUI
import KeyboardShortcuts

@main
struct KawaruApp: App {
    @State private var manager = InputSourceManager()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        MenuBarExtra("Kawaru", systemImage: "keyboard") {
            MenuBarMenu(manager: manager, openSettings: {
                NSApp.setActivationPolicy(.regular)
                NSApp.activate()
                openWindow(id: "settings")
            })
        }

        Window("Kawaru Settings", id: "settings") {
            SettingsView(manager: manager)
                .onDisappear {
                    NSApp.setActivationPolicy(.accessory)
                }
        }
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.suppressed)
    }
}
