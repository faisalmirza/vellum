import SwiftUI

struct ContentView: View {
    @Binding var document: MarkdownDocument
    @State private var previewHTML: String = ""

    var body: some View {
        HSplitView {
            EditorView(text: $document.text)
                .frame(minWidth: 300)

            PreviewView(html: previewHTML)
                .frame(minWidth: 300)
        }
        .onChange(of: document.text) { newValue in
            updatePreview(newValue)
        }
        .onAppear {
            updatePreview(document.text)
        }
    }

    private func updatePreview(_ markdown: String) {
        let escaped = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "\n", with: "\\n")
        previewHTML = escaped
    }
}
