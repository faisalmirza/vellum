import SwiftUI
import AppKit

struct ContentView: View {
    @Binding var document: MarkdownDocument
    @EnvironmentObject var updateChecker: UpdateChecker
    @State private var previewHTML: String = ""
    @State private var showEditor: Bool = false
    @State private var showFileBrowser: Bool = false
    @State private var siblingFiles: [URL] = []

    private let editorWidth: CGFloat = 400

    private var wordCount: Int {
        document.text.split { $0.isWhitespace || $0.isNewline }.count
    }

    private var charCount: Int {
        document.text.count
    }

    private var currentFileURL: URL? {
        NSDocumentController.shared.currentDocument?.fileURL
    }

    var body: some View {
        VStack(spacing: 0) {
            // Update banner
            if updateChecker.updateAvailable, let version = updateChecker.latestVersion {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.white)

                    if updateChecker.isDownloading {
                        Text("Updating to \(version)...")
                            .fontWeight(.medium)
                        Spacer()
                        ProgressView(value: updateChecker.downloadProgress)
                            .progressViewStyle(.linear)
                            .frame(width: 100)
                            .tint(.white)
                    } else if let error = updateChecker.updateError {
                        Text(error)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Retry") {
                            updateChecker.performUpdate()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                    } else {
                        Text("Vellum \(version) is available")
                            .fontWeight(.medium)
                        Spacer()
                        Button("Update") {
                            updateChecker.performUpdate()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                    }

                    if !updateChecker.isDownloading {
                        Button(action: { updateChecker.dismissUpdate() }) {
                            Image(systemName: "xmark")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .font(.system(size: 12))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.accentColor)
            }

            HStack(spacing: 0) {
            // Preview panel (always visible)
            ZStack(alignment: .topTrailing) {
                PreviewView(html: previewHTML)

                HStack(spacing: 8) {
                    // File browser button
                    Button(action: { loadSiblingFiles(); showFileBrowser.toggle() }) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Browse files in folder")
                    .popover(isPresented: $showFileBrowser, arrowEdge: .bottom) {
                        FileBrowserView(files: siblingFiles, currentFile: currentFileURL, onSelect: openFile)
                    }

                    // Show in Finder button
                    Button(action: showInFinder) {
                        Image(systemName: "folder")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help("Show in Finder")
                    .disabled(currentFileURL == nil)

                    // Toggle editor button
                    Button(action: toggleEditor) {
                        Image(systemName: showEditor ? "sidebar.right" : "sidebar.left")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .help(showEditor ? "Hide editor (⌘E)" : "Show editor (⌘E)")
                    .keyboardShortcut("e", modifiers: .command)
                }
                .padding(12)
            }
            .frame(minWidth: 300)

            // Editor panel (slides in/out from right)
            if showEditor {
                Divider()

                VStack(spacing: 0) {
                    EditorView(text: $document.text)

                    // Status bar
                    HStack {
                        Text("\(wordCount) words · \(charCount) characters")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                }
                .frame(width: editorWidth)
                .transition(.move(edge: .trailing))
            }
            }
        }
        .frame(minWidth: 400, minHeight: 400)
        .onChange(of: document.text) { newValue in
            updatePreview(newValue)
        }
        .onAppear {
            updatePreview(document.text)
            setupWindowFrameAutosave()
        }
    }

    private func toggleEditor() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showEditor.toggle()
        }
    }

    private func showInFinder() {
        guard let url = currentFileURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func updatePreview(_ markdown: String) {
        let escaped = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "\n", with: "\\n")
        previewHTML = escaped
    }

    private func loadSiblingFiles() {
        guard let currentDoc = NSDocumentController.shared.currentDocument,
              let fileURL = currentDoc.fileURL else {
            siblingFiles = []
            return
        }

        let folderURL = fileURL.deletingLastPathComponent()
        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsHiddenFiles]
            )
            siblingFiles = contents
                .filter { $0.pathExtension.lowercased() == "md" || $0.pathExtension.lowercased() == "markdown" }
                .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
        } catch {
            siblingFiles = []
        }
    }

    private func setupWindowFrameAutosave() {
        DispatchQueue.main.async {
            if let window = NSApp.keyWindow {
                window.setFrameAutosaveName("EfemdeMainWindow")
            }
        }
    }

    private func openFile(_ url: URL) {
        showFileBrowser = false

        // Read the new file and replace content
        do {
            let content = try String(contentsOf: url, encoding: .utf8)

            // Update the document's file URL first
            if let currentDoc = NSDocumentController.shared.currentDocument {
                currentDoc.fileURL = url
            }

            // Update content
            document.text = content

            // Update window title
            if let window = NSApp.keyWindow {
                window.title = url.lastPathComponent
                window.representedURL = url
                window.isDocumentEdited = false
            }

            // Clear change count after a brief delay to ensure SwiftUI has processed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let currentDoc = NSDocumentController.shared.currentDocument {
                    currentDoc.updateChangeCount(.changeCleared)
                }
                if let window = NSApp.keyWindow {
                    window.isDocumentEdited = false
                }
            }
        } catch {
            print("Error reading file: \(error)")
        }
    }
}

struct FileBrowserView: View {
    let files: [URL]
    let currentFile: URL?
    let onSelect: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Files in folder")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 6)

            Divider()

            if files.isEmpty {
                Text("No markdown files found")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .padding(12)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(files, id: \.self) { file in
                            let isCurrent = file == currentFile
                            Button(action: { if !isCurrent { onSelect(file) } }) {
                                HStack {
                                    Image(systemName: isCurrent ? "doc.text.fill" : "doc.text")
                                        .foregroundColor(isCurrent ? .accentColor : .secondary)
                                    Text(file.lastPathComponent)
                                        .fontWeight(isCurrent ? .medium : .regular)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                    Spacer()
                                    if isCurrent {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .background(isCurrent ? Color.accentColor.opacity(0.1) : Color.primary.opacity(0.001))
                            .cornerRadius(4)
                        }
                    }
                    .padding(.vertical, 6)
                }
                .frame(maxHeight: 300)
            }
        }
        .frame(width: 250)
    }
}
