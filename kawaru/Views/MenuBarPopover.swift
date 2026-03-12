import SwiftUI

struct MenuBarMenu: View {
    @Bindable var manager: InputSourceManager
    var openSettings: () -> Void

    var body: some View {
        ForEach(manager.sources) { source in
            let isActive = manager.currentSource == source

            Button {
                manager.switchTo(source)
            } label: {
                HStack {
                    Text(source.name)
                    if isActive {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        }

        Divider()

        Button("Settings\u{2026}") {
            openSettings()
        }
        .keyboardShortcut(",", modifiers: .command)

        Button("Quit Kawaru") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
