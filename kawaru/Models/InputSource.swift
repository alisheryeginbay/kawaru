import AppKit
import Carbon

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

    // MARK: - Selection

    @discardableResult
    func select() -> Bool {
        TISSelectInputSource(tisSource) == noErr
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
