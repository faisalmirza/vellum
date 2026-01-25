import Cocoa
import Quartz
import WebKit

class PreviewProvider: QLPreviewProvider, QLPreviewingController {
    func providePreview(for request: QLFilePreviewRequest) async throws -> QLPreviewReply {
        let fileURL = request.fileURL
        let markdown = try String(contentsOf: fileURL, encoding: .utf8)

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
            <script>document.write(marked.parse(\(markdown.debugDescription)));</script>
        </body>
        </html>
        """

        return QLPreviewReply(dataOfContentType: .html, contentSize: CGSize(width: 800, height: 600)) { reply in
            return html.data(using: .utf8)!
        }
    }
}
