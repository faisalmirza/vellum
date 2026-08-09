# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Debug build
xcodebuild -scheme vellum -configuration Debug build

# Release archive (Developer ID - direct distribution / Homebrew)
xcodebuild -scheme vellum -configuration Release -archivePath build/Vellum.xcarchive archive

# App Store archive
xcodebuild -scheme vellum-appstore -configuration AppStore -archivePath build/Vellum-AppStore.xcarchive archive

# Export app from archive (Developer ID)
xcodebuild -exportArchive -archivePath build/Vellum.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/export
```

## Architecture

Vellum is a SwiftUI markdown viewer for macOS with AppKit integration for native text editing and web-based preview.

### Core Components

- **VellumApp.swift** - App entry point using DocumentGroup for file handling
- **MarkdownDocument.swift** - FileDocument implementation for .md/.markdown files
- **ContentView.swift** - Main layout with split-panel (preview + toggleable editor), file browser popover, update banner
- **EditorView.swift** - NSViewRepresentable wrapping NSTextView with regex-based syntax highlighting
- **PreviewView.swift** - NSViewRepresentable using WKWebView + marked.js for HTML rendering
- **UpdateChecker.swift** - Singleton that checks GitHub releases, downloads updates, and triggers self-replacement via shell script

### QuickLook Extension

`QuickLookExtension/PreviewProvider.swift` - QLPreviewProvider with inlined marked.js for Finder preview.

## Key Patterns

- **AppKit bridges**: NSViewRepresentable used for NSTextView (editor) and WKWebView (preview)
- **Self-update mechanism**: Downloads zip, extracts, spawns bash script to replace app while terminating, then relaunches. Disabled in App Store builds via `#if !APP_STORE`.
- **Markdown pipeline**: Text → JavaScript escape → marked.js → HTML → WebView
- **State management**: @StateObject for UpdateChecker singleton, @Binding for document text
- **Conditional compilation**: `APP_STORE` Swift flag disables self-update UI and UpdateChecker in App Store builds

## Release Process

Automated via `.github/workflows/release.yml`:
- Triggers on push to main that changes `vellum/**`
- Bumps patch version in project.pbxproj
- Builds, archives, creates GitHub release
- Updates homebrew cask (requires TAP_TOKEN secret)

## Code Signing & Distribution

- **Team ID**: RFW3QATUR9
- **Two distribution channels**:
  - **Developer ID** (Release config): Direct download / Homebrew. Sandbox disabled, self-update enabled. Uses `vellum/vellum.entitlements`.
  - **App Store** (AppStore config): Mac App Store. Sandbox enabled, self-update disabled. Uses `vellum/vellum-appstore.entitlements`.
- **Schemes**: `vellum` (Developer ID), `vellum-appstore` (App Store)
- **Notarization**: Credentials stored in Keychain as profile "Vellum-Notarize". Submit via `xcrun notarytool submit --keychain-profile "Vellum-Notarize" --wait`

## Notes

- Bundle identifier: `com.faisalmirza.vellum`
- QuickLook extension identifier: `com.faisalmirza.vellum.quicklook`
- Minimum macOS: 13.0 (Ventura)
