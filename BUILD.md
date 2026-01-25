# Building efemde

This document provides detailed instructions for building, testing, and distributing the efemde markdown editor.

## Prerequisites

- **macOS**: 13.0 (Ventura) or later
- **Xcode**: 15.0 or later
- **Development Tools**: Command Line Tools for Xcode

## Project Structure

The project consists of two targets:

1. **efemde** (Main App): The markdown editor application
2. **QuickLookExtension**: App extension for previewing markdown files in Finder

## Building from Source

### Option 1: Using Xcode

1. Open the project:
   ```bash
   cd efemde
   open efemde.xcodeproj
   ```

2. Select the `efemde` scheme in the toolbar

3. Build the project:
   - Press `⌘B` or select `Product > Build`

4. Run the application:
   - Press `⌘R` or select `Product > Run`

### Option 2: Using xcodebuild (Command Line)

```bash
# Build the app
xcodebuild -project efemde.xcodeproj \
           -scheme efemde \
           -configuration Release \
           build

# The built app will be in:
# build/Release/efemde.app
```

## Testing the Application

### Manual Testing Checklist

- [ ] **Launch Test**: App launches successfully
- [ ] **New Document**: Create new document shows default content
- [ ] **Syntax Highlighting**: Type markdown and verify colors:
  - Headers (`# Title`) appear in blue
  - Bold (`**text**`) appears in orange
  - Italic (`*text*`) appears in green
  - Inline code (`` `code` ``) appears in purple
  - Links (`[text](url)`) appear in teal
- [ ] **Live Preview**: Changes in editor immediately update preview
- [ ] **Save/Open**: Save `.md` file and reopen it
- [ ] **Dark Mode**: Toggle system dark mode, verify both panes adapt
- [ ] **File Association**: Double-click a `.md` file in Finder

### Testing the QuickLook Extension

1. Build and run the app at least once
2. Create a test markdown file:
   ```bash
   echo "# Test\n\nThis is a **test** markdown file." > test.md
   ```
3. Open Finder and navigate to the file
4. Select the file and press `Space`
5. Verify the markdown preview appears

**Note**: QuickLook extensions may require:
- Restarting Finder: `killall Finder`
- Resetting QuickLook cache: `qlmanage -r`
- Logging out and back in

## Creating a Distributable Build

### Option 1: Archive for Distribution

1. In Xcode, select `Product > Archive`
2. Once complete, the Organizer window opens
3. Select your archive and click `Distribute App`
4. Choose distribution method:
   - **Copy App**: For local installation
   - **Mac App Store**: For App Store distribution
   - **Developer ID**: For distribution outside App Store

### Option 2: Build for Release (Manual)

```bash
# Build release version
xcodebuild -project efemde.xcodeproj \
           -scheme efemde \
           -configuration Release \
           -derivedDataPath ./build \
           build

# Find the built app
find ./build -name "efemde.app" -type d
```

## Installing the Application

1. Copy the built app to Applications:
   ```bash
   cp -R build/Release/efemde.app /Applications/
   ```

2. Register with Launch Services (for file associations):
   ```bash
   /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/efemde.app
   ```

3. Verify registration:
   ```bash
   # Check if .md files can be opened with efemde
   mdls -name kMDItemContentType -name kMDItemContentTypeTree test.md
   ```

## Troubleshooting

### Build Issues

**Problem**: Build fails with "No such module 'SwiftUI'"
- **Solution**: Ensure deployment target is macOS 13.0 or later

**Problem**: Code signing errors
- **Solution**: In Xcode, go to Signing & Capabilities and:
  - Set "Automatically manage signing" 
  - Select your development team
  - Or change "Code Sign Style" to "Sign to Run Locally"

### QuickLook Issues

**Problem**: QuickLook preview doesn't work
- **Solution**: Try these steps in order:
  1. Rebuild and run the app from Xcode
  2. Reset QuickLook: `qlmanage -r && qlmanage -r cache`
  3. Restart Finder: `killall Finder`
  4. Log out and log back in
  5. Check Console.app for errors related to "qlmanage" or "efemde"

**Problem**: Extension shows raw markdown instead of rendered HTML
- **Solution**: Check that marked.js is loading properly (requires internet connection for CDN)

### File Association Issues

**Problem**: .md files don't open with efemde
- **Solution**: 
  1. Right-click a .md file in Finder
  2. Select "Get Info"
  3. Under "Open with:", select efemde
  4. Click "Change All..." to apply to all .md files

## Development Tips

### Debugging

- Use Xcode's debugger (`⌘\` to set breakpoints)
- View console output in Xcode's debug area
- For QuickLook debugging, check Console.app and filter for "qlmanage"

### Hot Reload

SwiftUI supports preview mode in Xcode:
1. Open any .swift file
2. Press `⌘⌥P` to show preview
3. Click "Resume" if paused
4. Edit code and see changes live

### Code Formatting

The project follows Swift standard formatting:
- 4 spaces for indentation
- No trailing whitespace
- SwiftLint rules (if integrated)

## Clean Build

If you encounter issues, perform a clean build:

```bash
# In Xcode
Product > Clean Build Folder (⌘⇧K)

# Or via command line
xcodebuild clean -project efemde.xcodeproj -scheme efemde
rm -rf ~/Library/Developer/Xcode/DerivedData/efemde-*
```

## Continuous Integration

For CI/CD pipelines (GitHub Actions, etc.):

```yaml
- name: Build efemde
  run: |
    xcodebuild -project efemde.xcodeproj \
               -scheme efemde \
               -configuration Release \
               -destination 'platform=macOS' \
               build
```

## Support

For issues or questions:
- Check existing [GitHub Issues](https://github.com/faisalmirza/efemde/issues)
- Create a new issue with:
  - macOS version
  - Xcode version
  - Build log output
  - Steps to reproduce
