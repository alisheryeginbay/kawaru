import SwiftUI
import KeyboardShortcuts

struct ShortcutRow: View {
    let source: InputSource

    var body: some View {
        LabeledContent {
            KeyboardShortcuts.Recorder(
                for: ShortcutNameMapping.shortcutName(for: source.id)
            )
        } label: {
            HStack(spacing: 8) {
                if let icon = source.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                }

                Text(source.name)
            }
        }
    }
}
