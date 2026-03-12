# Kawaru

A macOS Tahoe input source switcher. Assign global keyboard shortcuts to your input sources and switch instantly.

Spiritual successor to [Kawa](https://github.com/hatashiro/kawa), rebuilt from scratch with Swift 6 and SwiftUI.

## Features

- Global keyboard shortcuts per input source
- Native menu bar dropdown with active source indicator
- Settings with Liquid Glass UI
- Launch at login
- Optional notifications on switch
- Automatic source list updates when layouts change

## Requirements

- macOS 26 (Tahoe) or later

## Building

Open `kawaru.xcodeproj` in Xcode 26 and build. The single dependency ([KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)) resolves automatically via SPM.

## Usage

1. Click the keyboard icon in the menu bar
2. Open **Settings** and go to the **Shortcuts** tab
3. Record a shortcut for each input source
4. Press the shortcut anywhere to switch instantly

## Known Limitations

- `TISSelectInputSource` has a known Carbon bug with some CJKV input methods

## Credits

- [Kawa](https://github.com/hatashiro/kawa) by [@hatashiro](https://github.com/hatashiro) — the original inspiration
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) by [@sindresorhus](https://github.com/sindresorhus)

## License

MIT
