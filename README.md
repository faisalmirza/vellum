<p align="center">
  <img src="logo.png" width="128" height="128" alt="Vellum logo">
</p>

<h1 align="center">Vellum</h1>

<p align="center">
  <strong>A fast, native markdown viewer for macOS with QuickLook support</strong>
</p>

<p align="center">
  <a href="https://github.com/faisalmirza/vellum/releases/latest"><img src="https://img.shields.io/github/v/release/faisalmirza/vellum?style=flat-square" alt="Latest Release"></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=flat-square" alt="macOS 13.0+">
  <img src="https://img.shields.io/badge/signed%20%26%20notarized-Apple%20Developer%20ID-brightgreen?style=flat-square" alt="Signed and notarized">
  <img src="https://img.shields.io/github/license/faisalmirza/vellum?style=flat-square" alt="MIT License">
  <a href="https://github.com/faisalmirza/vellum/releases"><img src="https://img.shields.io/github/downloads/faisalmirza/vellum/total?style=flat-square" alt="Downloads"></a>
</p>

<p align="center">
  <img src="screenshot.png" width="720" alt="Vellum screenshot">
</p>

## Why Vellum?

- **QuickLook Integration** - Preview markdown files in Finder by pressing Space. No app launch needed.
- **Lightweight & Fast** - Native SwiftUI app. Opens instantly, uses minimal resources.
- **Just Works** - No configuration, no fuss. Open a file and start reading.

## Installation

### Homebrew (recommended)

```bash
brew install --cask faisalmirza/tap/vellum-md
```

### Manual Download

1. Download the latest `.zip` from [Releases](https://github.com/faisalmirza/vellum/releases/latest)
2. Unzip and drag `Vellum.app` to Applications
3. See [First Launch](#first-launch) below

## Features

| Feature | Description |
|---------|-------------|
| **QuickLook Preview** | Press Space in Finder to preview any `.md` file |
| **Live Editor** | Toggle with `⌘E` to edit alongside the preview |
| **File Browser** | Switch between markdown files in the same folder |
| **Show in Finder** | Reveal the current file in Finder with one click |
| **Dark Mode** | Automatically adapts to your system appearance |
| **Syntax Highlighting** | Color-coded markdown in the editor |
| **Anchor Links** | Click headings in the preview to jump to sections |
| **Auto-Update** | Get notified when new versions are available |

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘E` | Toggle editor panel |
| `⌘O` | Open file |
| `⌘S` | Save |
| `⌘W` | Close window |

## QuickLook Setup

After installing, the QuickLook extension should work automatically. If markdown files still show as plain text in QuickLook:

1. Open Vellum once (this registers the extension)
2. Go to **System Settings → Privacy & Security → Extensions → Quick Look**
3. Enable **Vellum**

## First Launch

Just double-click it. Vellum is signed with an Apple Developer ID certificate and notarized by Apple, so macOS opens it without a warning. You don't need to right-click to open it, visit Privacy & Security, or run `xattr`.

### Verifying the signature

To confirm your copy is genuine and unmodified:

```bash
# Expect: source=Notarized Developer ID
spctl -a -vvv -t exec /Applications/Vellum.app

# Expect: Authority=Developer ID Application: Faisal Mirza (RFW3QATUR9)
codesign -dv --verbose=2 /Applications/Vellum.app 2>&1 | grep Authority
```

The notarization ticket is stapled to the app, so both checks work offline.

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel — Vellum ships as a universal binary

## Built With

- SwiftUI + AppKit
- [Marked.js](https://github.com/markedjs/marked) for markdown rendering
- [Highlight.js](https://highlightjs.org/) for code syntax highlighting

## Contributing

Contributions welcome! Feel free to open issues or submit pull requests.

## License

MIT
