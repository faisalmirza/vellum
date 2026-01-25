# Contributing to efemde

Thank you for your interest in contributing to efemde! This document provides guidelines and information for contributors.

## Project Overview

efemde is a native macOS markdown editor built with SwiftUI and AppKit. The goal is to provide a fast, lightweight, and native experience for editing markdown files.

## Code Structure

### Main Application (`efemde/`)

- **EfemdeApp.swift**: Application entry point using SwiftUI's `@main` and `DocumentGroup`
- **MarkdownDocument.swift**: Document model conforming to `FileDocument` protocol
- **ContentView.swift**: Main split view container managing editor and preview
- **EditorView.swift**: Text editor using `NSTextView` with syntax highlighting
- **PreviewView.swift**: HTML preview using `WKWebView` and Marked.js

### QuickLook Extension (`QuickLookExtension/`)

- **PreviewProvider.swift**: Implementation of `QLPreviewingController` for markdown preview in Finder

## Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/efemde.git
   cd efemde
   ```

2. **Open in Xcode**
   ```bash
   open efemde.xcodeproj
   ```

3. **Build and run**
   - Press `⌘R` to build and run

## Coding Guidelines

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use 4 spaces for indentation (no tabs)
- Maximum line length: 120 characters
- Use meaningful variable and function names

### SwiftUI Best Practices

- Prefer `@State` for view-local state
- Use `@Binding` for parent-child data flow
- Keep view bodies simple and extract subviews when needed
- Use `@StateObject` for observable objects owned by the view

### Code Organization

- One type per file (unless tightly coupled)
- Group related files in the project navigator
- Add comments for complex logic
- Use `// MARK:` to organize code sections

## Feature Development

### Adding New Features

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Implement the feature**
   - Write clean, maintainable code
   - Follow existing patterns
   - Test thoroughly on your local machine

3. **Test your changes**
   - Manual testing on macOS 13.0+
   - Test both light and dark modes
   - Test file open/save operations
   - Verify QuickLook still works

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "Add feature: description of your feature"
   ```

5. **Push and create a pull request**
   ```bash
   git push origin feature/your-feature-name
   ```

### Feature Ideas

Some ideas for future enhancements:

- Export to HTML/PDF
- Custom syntax themes
- Configurable preview styles
- Keyboard shortcuts customization
- Markdown table editor
- Image drag-and-drop support
- Split view resize persistence
- Font size controls
- Word/character count
- Spell check integration

## Bug Reports

When reporting bugs, please include:

- macOS version
- Xcode version (if building from source)
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots if applicable
- Console logs from Console.app (filter for "efemde")

## Pull Request Process

1. **Before submitting**:
   - Ensure your code builds without warnings
   - Test all functionality manually
   - Update documentation if needed
   - Add comments for complex code

2. **Pull request checklist**:
   - [ ] Code builds successfully
   - [ ] No new warnings introduced
   - [ ] Feature works in both light and dark modes
   - [ ] File operations (save/open) work correctly
   - [ ] Documentation updated if needed
   - [ ] README.md updated for significant features

3. **Review process**:
   - Maintainers will review your PR
   - Address any feedback or requested changes
   - Once approved, your PR will be merged

## Architecture Decisions

### Why SwiftUI + AppKit?

- SwiftUI provides modern declarative UI
- AppKit's `NSTextView` offers mature text editing with undo/redo
- Hybrid approach leverages strengths of both frameworks

### Why WKWebView for Preview?

- Native HTML rendering
- Automatic dark mode support
- Good performance
- Security sandboxing

### Why Marked.js from CDN?

- Industry-standard markdown parser
- Automatic updates to latest version
- Smaller app bundle size
- Note: Requires internet connection for first load

### File Format: UTType

We use `net.daringfireball.markdown` as the UTType identifier for maximum compatibility with other markdown editors.

## Testing

Currently, efemde uses manual testing. Automated tests would be a welcome contribution!

### Manual Test Checklist

- [ ] App launches without errors
- [ ] New document shows default content
- [ ] Syntax highlighting works for:
  - [ ] Headers (# through ######)
  - [ ] Bold (**text**)
  - [ ] Italic (*text*)
  - [ ] Inline code (`code`)
  - [ ] Code blocks (```code```)
  - [ ] Links ([text](url))
- [ ] Live preview updates as you type
- [ ] Save and open files work correctly
- [ ] File associations work (.md files)
- [ ] QuickLook extension shows preview
- [ ] Dark mode works in both editor and preview
- [ ] Undo/redo works in editor

## Performance Considerations

- Syntax highlighting runs on every text change - could be optimized for large files
- Preview updates on every keystroke - consider debouncing for very large documents
- WebView loads Marked.js from CDN - could be bundled locally

## Security

- App uses sandbox with file access permissions
- Network access required for loading Marked.js
- No telemetry or analytics
- No data collection

## Questions?

- Open an issue for questions
- Check existing issues for similar questions
- Review the code - it's relatively simple and well-commented

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for contributing to efemde! 🎉
