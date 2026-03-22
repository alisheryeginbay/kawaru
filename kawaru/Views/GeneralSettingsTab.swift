import SwiftUI
import ServiceManagement

struct GeneralSettingsTab: View {
    @Bindable var manager: InputSourceManager
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        launchAtLogin = SMAppService.mainApp.status == .enabled
                    }
                }

            Toggle("Show notification on switch", isOn: $manager.showsNotification)

            Section {} footer: {
                VStack(spacing: 4) {
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Kawaru v\(version)")
                    }
                    Link("GitHub", destination: URL(string: "https://github.com/alisheryeginbay/kawaru")!)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .formStyle(.grouped)
    }
}
