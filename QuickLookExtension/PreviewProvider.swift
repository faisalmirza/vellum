import Cocoa
import Quartz

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let markdown = try String(contentsOf: request.fileURL, encoding: .utf8)
        let escaped = markdown
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")

        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
            <style>
                body { font-family: -apple-system; padding: 20px; line-height: 1.6; }
                @media (prefers-color-scheme: dark) {
                    body { background: #1e1e1e; color: #d4d4d4; }
                }
                code { background: #f0f0f0; padding: 2px 6px; border-radius: 4px; }
                pre { background: #f0f0f0; padding: 12px; border-radius: 8px; }
                @media (prefers-color-scheme: dark) {
                    code, pre { background: #2d2d2d; }
                }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                document.getElementById('content').innerHTML = marked.parse("\(escaped)");
            </script>
        </body>
        </html>
        """

        return QLPreviewReply(dataOfContentType: .html, contentSize: CGSize(width: 800, height: 600)) { _ in
            html.data(using: .utf8)!
        }
    }
}
