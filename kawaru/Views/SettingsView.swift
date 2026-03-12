import SwiftUI

struct SettingsView: View {
    @Bindable var manager: InputSourceManager

    var body: some View {
        TabView {
            Tab("Shortcuts", systemImage: "keyboard") {
                shortcutsTab
            }

            Tab("General", systemImage: "gear") {
                GeneralSettingsTab(manager: manager)
            }
        }
        .frame(width: 420, height: 320)
    }

    private var shortcutsTab: some View {
        Form {
            if manager.sources.isEmpty {
                ContentUnavailableView(
                    "No Input Sources",
                    systemImage: "keyboard",
                    description: Text("Add keyboard layouts in System Settings.")
                )
            } else {
                Section {
                    ForEach(manager.sources) { source in
                        ShortcutRow(source: source)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}
