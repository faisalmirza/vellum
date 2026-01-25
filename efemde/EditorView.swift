import SwiftUI
import AppKit

struct EditorView: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.delegate = context.coordinator
        textView.string = text

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        let textView = nsView.documentView as! NSTextView
        if textView.string != text {
            textView.string = text
        }
        highlightSyntax(textView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    private func highlightSyntax(_ textView: NSTextView) {
        let text = textView.string
        let fullRange = NSRange(location: 0, length: text.utf16.count)

        textView.textStorage?.beginEditing()
        textView.textStorage?.setAttributes([
            .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            .foregroundColor: NSColor.textColor
        ], range: fullRange)

        let patterns: [(String, NSColor)] = [
            ("^#{1,6} .+$", .systemBlue),           // Headers
            ("\\*\\*[^*]+\\*\\*", .systemOrange),   // Bold
            ("\\*[^*]+\\*", .systemGreen),          // Italic
            ("`[^`]+`", .systemPurple),             // Inline code
            ("^```[\\s\\S]*?```$", .systemPurple),  // Code blocks
            ("\\[.+\\]\\(.+\\)", .systemTeal),      // Links
        ]

        for (pattern, color) in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) {
                let matches = regex.matches(in: text, range: fullRange)
                for match in matches {
                    textView.textStorage?.addAttribute(.foregroundColor, value: color, range: match.range)
                }
            }
        }

        textView.textStorage?.endEditing()
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: EditorView

        init(_ parent: EditorView) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
        }
    }
}
