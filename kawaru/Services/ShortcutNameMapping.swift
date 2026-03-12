import KeyboardShortcuts

/// Maps TIS input source IDs (containing dots) to KeyboardShortcuts.Name (which warns on dots).
/// Uses a deterministic, reversible dot↔hyphen replacement.
enum ShortcutNameMapping {
    static func shortcutName(for sourceID: String) -> KeyboardShortcuts.Name {
        let sanitized = sourceID.replacingOccurrences(of: ".", with: "-")
        return KeyboardShortcuts.Name(sanitized)
    }

    static func sourceID(from shortcutName: KeyboardShortcuts.Name) -> String {
        shortcutName.rawValue.replacingOccurrences(of: "-", with: ".")
    }
}
