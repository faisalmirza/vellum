# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Debug build
xcodebuild -scheme vellum -configuration Debug build

# Release archive
xcodebuild -scheme vellum -configuration Release -archivePath build/Vellum.xcarchive archive

# Export app from archive
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
- **Self-update mechanism**: Downloads zip, extracts, spawns bash script to replace app while terminating, then relaunches
- **Markdown pipeline**: Text → JavaScript escape → marked.js → HTML → WebView
- **State management**: @StateObject for UpdateChecker singleton, @Binding for document text

## Release Process

Automated via `.github/workflows/release.yml`:
- Triggers on push to main that changes `vellum/**`
- Bumps patch version in project.pbxproj
- Builds, archives, creates GitHub release
- Updates homebrew cask (requires TAP_TOKEN secret)

## Notes

- App sandbox disabled in entitlements to allow shell script execution for updates
- Bundle identifier: `com.faisalmirza.vellum`
- Minimum macOS: 13.0 (Ventura)
