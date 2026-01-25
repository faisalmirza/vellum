# efemde

Fast markdown editor for macOS with live preview and QuickLook support.

## Features

- **Split View Editor**: Edit markdown on the left, see live preview on the right
- **Syntax Highlighting**: Color-coded markdown syntax in the editor
- **Live Preview**: Real-time HTML preview using Marked.js
- **QuickLook Extension**: Press Space in Finder to preview .md files
- **File Associations**: Opens .md and .markdown files by default
- **Dark Mode Support**: Adapts to system appearance

## Building

### Requirements
- macOS 13.0 or later
- Xcode 15.0 or later

### Build Instructions

1. Open `efemde.xcodeproj` in Xcode
2. Select Product > Build (⌘B)
3. Run the app (⌘R) or create an archive

### Installation

1. Build the project in Xcode
2. Select Product > Archive
3. Choose "Distribute App" > "Copy App"
4. Move `efemde.app` to `/Applications`
5. Register the app with Launch Services:
   ```bash
   /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/efemde.app
   ```

## Usage

- Open any `.md` or `.markdown` file with efemde
- Type in the left editor pane, see live preview on the right
- Press Space on a markdown file in Finder to see QuickLook preview

## Tech Stack

- SwiftUI + AppKit for native macOS UI
- WKWebView for rendering HTML preview
- Marked.js (loaded from CDN) for markdown parsing
- QuickLook framework for preview extension

## Project Structure

```
efemde/
├── efemde/                      # Main app
│   ├── EfemdeApp.swift         # App entry point
│   ├── MarkdownDocument.swift  # Document model
│   ├── ContentView.swift       # Split view container
│   ├── EditorView.swift        # Text editor with syntax highlighting
│   ├── PreviewView.swift       # WebKit markdown preview
│   ├── Info.plist              # App configuration
│   ├── efemde.entitlements     # App permissions
│   └── Assets.xcassets/        # App icons and assets
└── QuickLookExtension/          # QuickLook extension
    ├── PreviewProvider.swift   # QL preview implementation
    └── Info.plist              # Extension configuration
```

## License

See [Issue #1](https://github.com/faisalmirza/efemde/issues/1) for implementation spec.
