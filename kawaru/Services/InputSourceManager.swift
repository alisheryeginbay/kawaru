import AppKit
import KeyboardShortcuts
import Observation

@MainActor
@Observable
final class InputSourceManager {
    private(set) var sources: [InputSource] = []
    private(set) var currentSource: InputSource?

    var showsNotification: Bool {
        didSet { UserDefaults.standard.set(showsNotification, forKey: "showsNotification") }
    }

    init() {
        self.showsNotification = UserDefaults.standard.bool(forKey: "showsNotification")
        discoverSources()
        registerShortcuts()
        observeSystemNotifications()
    }

    // MARK: - Source Management

    func discoverSources() {
        sources = InputSource.allSelectable()
        currentSource = InputSource.current()
        registerShortcuts()
    }

    func switchTo(_ source: InputSource) {
        guard source.select() else { return }
        currentSource = source
        if showsNotification {
            NotificationHelper.send(sourceName: source.name)
        }
    }

    // MARK: - Shortcut Registration

    private func registerShortcuts() {
        for source in sources {
            let name = ShortcutNameMapping.shortcutName(for: source.id)
            KeyboardShortcuts.onKeyUp(for: name) { [weak self] in
                Task { @MainActor in
                    self?.switchTo(source)
                }
            }
        }
    }

    // MARK: - System Notifications

    private func observeSystemNotifications() {
        let center = DistributedNotificationCenter.default()

        // Selected input source changed (by user or system)
        center.addObserver(
            forName: .init("com.apple.Carbon.TISNotifySelectedKeyboardInputSourceChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.currentSource = InputSource.current()
            }
        }

        // Enabled input sources changed (user added/removed layouts)
        center.addObserver(
            forName: .init("com.apple.Carbon.TISNotifyEnabledKeyboardInputSourcesChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.discoverSources()
            }
        }
    }
}
