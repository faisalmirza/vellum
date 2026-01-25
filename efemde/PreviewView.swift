import SwiftUI
import WebKit

struct PreviewView: NSViewRepresentable {
    let html: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.setValue(false, forKey: "drawsBackground")
        context.coordinator.webView = webView
        webView.loadHTMLString(baseHTML(), baseURL: nil)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        context.coordinator.pendingMarkdown = html
        context.coordinator.updateIfReady()
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var webView: WKWebView?
        var isReady = false
        var pendingMarkdown: String?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isReady = true
            updateIfReady()
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url {
                // Allow initial page load
                if navigationAction.navigationType == .other {
                    decisionHandler(.allow)
                    return
                }

                // Open external links in default browser
                if url.scheme == "http" || url.scheme == "https" {
                    NSWorkspace.shared.open(url)
                    decisionHandler(.cancel)
                    return
                }
            }
            // Allow all other navigation (including anchor links)
            decisionHandler(.allow)
        }

        func updateIfReady() {
            guard isReady, let markdown = pendingMarkdown, let webView = webView else { return }
            let js = "updatePreview(`\(markdown)`);"
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("JS Error: \(error)")
                }
            }
        }
    }

    private func baseHTML() -> String {
        """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="color-scheme" content="light dark">
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
            <style>
                :root {
                    color-scheme: light dark;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                    padding: 20px;
                    line-height: 1.6;
                    background: transparent;
                    color: #1d1d1f;
                    word-wrap: break-word;
                    overflow-wrap: break-word;
                }
                @media (prefers-color-scheme: dark) {
                    body { color: #f5f5f7; }
                    a { color: #6cb6ff; }
                    code { background: rgba(255,255,255,0.1); }
                    pre { background: rgba(255,255,255,0.1); }
                }
                @media (prefers-color-scheme: light) {
                    code { background: rgba(0,0,0,0.05); }
                    pre { background: rgba(0,0,0,0.05); }
                }
                code {
                    padding: 2px 6px;
                    border-radius: 4px;
                    font-family: SF Mono, monospace;
                    word-break: break-word;
                }
                pre {
                    padding: 12px;
                    border-radius: 8px;
                    overflow-x: auto;
                    white-space: pre-wrap;
                    word-wrap: break-word;
                }
                pre code { background: none; padding: 0; }

                /* Smooth scrolling */
                html {
                    scroll-behavior: smooth;
                }
            </style>
        </head>
        <body>
            <div id="content">Loading preview...</div>
            <script>
                function updatePreview(markdown) {
                    try {
                        document.getElementById('content').innerHTML = marked.parse(markdown);

                        // Add IDs to all headings for anchor links
                        document.querySelectorAll('h1, h2, h3, h4, h5, h6').forEach(function(heading) {
                            if (!heading.id) {
                                const slug = heading.textContent.toLowerCase()
                                    .replace(/[^a-z0-9\\s-]/g, '')
                                    .replace(/\\s+/g, '-')
                                    .replace(/-+/g, '-')
                                    .trim();
                                heading.id = slug;
                            }
                        });

                        // Handle anchor clicks
                        document.querySelectorAll('a[href^="#"]').forEach(function(link) {
                            link.onclick = function(e) {
                                e.preventDefault();
                                const targetId = this.getAttribute('href').substring(1);
                                const target = document.getElementById(targetId);
                                if (target) {
                                    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
                                }
                            };
                        });
                    } catch(e) {
                        document.getElementById('content').innerHTML = '<pre>' + e + '</pre>';
                    }
                }
            </script>
        </body>
        </html>
        """
    }
}
