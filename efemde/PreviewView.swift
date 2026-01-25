import SwiftUI
import WebKit

struct PreviewView: NSViewRepresentable {
    let html: String

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.loadHTMLString(baseHTML(), baseURL: nil)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let js = "updatePreview(`\(html)`);"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    private func baseHTML() -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    padding: 20px;
                    line-height: 1.6;
                }
                @media (prefers-color-scheme: dark) {
                    body { background: #1e1e1e; color: #d4d4d4; }
                    a { color: #6cb6ff; }
                    code { background: #2d2d2d; }
                    pre { background: #2d2d2d; }
                }
                code {
                    background: #f0f0f0;
                    padding: 2px 6px;
                    border-radius: 4px;
                    font-family: SF Mono, monospace;
                }
                pre {
                    background: #f0f0f0;
                    padding: 12px;
                    border-radius: 8px;
                    overflow-x: auto;
                }
                pre code { background: none; padding: 0; }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                function updatePreview(markdown) {
                    document.getElementById('content').innerHTML = marked.parse(markdown);
                }
            </script>
        </body>
        </html>
        """
    }
}
