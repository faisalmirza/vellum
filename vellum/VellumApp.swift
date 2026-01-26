import SwiftUI

@main
struct VellumApp: App {
    @StateObject private var updateChecker = UpdateChecker.shared

    init() {
        // Check for updates on launch
        UpdateChecker.shared.checkForUpdates()
        
        // Restore last opened file on launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let lastFileURL = LastFileManager.shared.getLastOpenedFile() {
                NSDocumentController.shared.openDocument(withContentsOf: lastFileURL, display: true) { _, _, _ in }
            }
        }
    }

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            ContentView(document: file.$document)
                .environmentObject(updateChecker)
        }
        .commands {
            CommandGroup(replacing: .help) { }
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    UpdateChecker.shared.checkForUpdates()
                    // Show alert if already up to date
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if !UpdateChecker.shared.updateAvailable {
                            showUpToDateAlert()
                        }
                    }
                }
            }
        }
    }

    private func showUpToDateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're up to date!"
        alert.informativeText = "Vellum \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") is the latest version."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
