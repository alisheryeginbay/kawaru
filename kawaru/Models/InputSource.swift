import AppKit
import Carbon

/// Borderless windows return `false` from `canBecomeKey` by default,
/// which prevents the CJKV helper window from reliably becoming the key window.
private final class KeyableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
}

@MainActor
struct InputSource: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: NSImage?

    private let tisSource: TISInputSource

    // MARK: - Discovery

    static func allSelectable() -> [InputSource] {
        let filter: [CFString: Any] = [
            kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource as Any,
            kTISPropertyInputSourceIsSelectCapable: true,
        ]
        guard let list = TISCreateInputSourceList(filter as CFDictionary, false)?
            .takeRetainedValue() as? [TISInputSource]
        else {
            return []
        }
        return list.compactMap { tis in
            guard let id = stringProperty(tis, kTISPropertyInputSourceID),
                  let name = stringProperty(tis, kTISPropertyLocalizedName)
            else {
                return nil
            }
            let icon = loadIcon(for: tis)
            return InputSource(id: id, name: name, icon: icon, tisSource: tis)
        }
        .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func current() -> InputSource? {
        guard let tis = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue(),
              let id = stringProperty(tis, kTISPropertyInputSourceID),
              let name = stringProperty(tis, kTISPropertyLocalizedName)
        else {
            return nil
        }
        return InputSource(id: id, name: name, icon: loadIcon(for: tis), tisSource: tis)
    }

    /// Whether this source is a CJKV input method that needs the temporary-window workaround.
    var isCJKV: Bool {
        guard id.contains("inputmethod") else { return false }
        guard let raw = TISGetInputSourceProperty(tisSource, kTISPropertyInputSourceLanguages),
              let languages = Unmanaged<CFArray>.fromOpaque(raw).takeUnretainedValue() as? [String],
              let primary = languages.first
        else {
            return false
        }
        return primary == "ko" || primary == "ja" || primary == "vi" || primary.hasPrefix("zh")
    }

    // MARK: - Selection

    @discardableResult
    func select() -> Bool {
        let wasCJKV = InputSource.current()?.isCJKV ?? false
        guard TISSelectInputSource(tisSource) == noErr else { return false }
        if isCJKV || wasCJKV {
            Self.refreshInputSourceWithTemporaryWindow()
        }
        return true
    }

    /// Reusable off-screen window for the CJKV workaround.
    /// Kept as a static to avoid repeated allocation and animation-related crashes on dealloc.
    private static let helperWindow: NSWindow = {
        let window = KeyableWindow(
            contentRect: NSRect(x: -9999, y: -9999, width: 1, height: 1),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.animationBehavior = .none
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]
        window.contentView = NSTextView(frame: NSRect(x: 0, y: 0, width: 1, height: 1))
        return window
    }()

    /// Work around a macOS Carbon bug where `TISSelectInputSource` updates the menu bar
    /// but doesn't actually activate CJKV input methods in the focused app.
    /// Creating a temporary key window forces macOS to re-query the active input source.
    private static func refreshInputSourceWithTemporaryWindow() {
        let previousApp = NSWorkspace.shared.frontmostApplication

        NSApp.activate()
        helperWindow.makeKeyAndOrderFront(nil)
        helperWindow.makeFirstResponder(helperWindow.contentView)

        DispatchQueue.main.async {
            helperWindow.orderOut(nil)
            if let app = previousApp {
                app.activate()
            }
        }
    }

    // MARK: - Hashable

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated static func == (lhs: InputSource, rhs: InputSource) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Private Helpers

    private static func stringProperty(_ source: TISInputSource, _ key: CFString) -> String? {
        guard let raw = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(raw).takeUnretainedValue() as String
    }

    private static func loadIcon(for source: TISInputSource) -> NSImage? {
        // Try icon image URL first
        if let raw = TISGetInputSourceProperty(source, kTISPropertyIconImageURL) {
            let url = Unmanaged<CFURL>.fromOpaque(raw).takeUnretainedValue() as URL
            if let image = NSImage(contentsOf: url) {
                image.size = NSSize(width: 18, height: 18)
                return image
            }
        }

        // Try IconRef
        if let raw = TISGetInputSourceProperty(source, kTISPropertyIconRef) {
            let iconRef = OpaquePointer(raw)
            let image = NSImage(iconRef: iconRef)
            image.size = NSSize(width: 18, height: 18)
            return image
        }

        // Fallback: SF Symbol
        return NSImage(systemSymbolName: "keyboard", accessibilityDescription: nil)
    }
}
