import SwiftUI

@main
struct VellumApp: App {
    @StateObject private var updateChecker = UpdateChecker.shared
    @StateObject private var appDelegate = AppDelegateHelper()

    init() {
        // Check for updates on launch
        UpdateChecker.shared.checkForUpdates()
    }

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            ContentView(document: file.$document)
                .environmentObject(updateChecker)
                .onAppear {
                    // Restore last opened file after first window appears
                    if !appDelegate.hasRestoredFile {
                        appDelegate.hasRestoredFile = true
                        restoreLastOpenedFile()
                    }
                }
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
    
    private func restoreLastOpenedFile() {
        guard let lastFileURL = LastFileManager.shared.getLastOpenedFile() else {
            return
        }
        
        NSDocumentController.shared.openDocument(withContentsOf: lastFileURL, display: true) { document, wasAlreadyOpen, error in
            if let error = error {
                print("Failed to restore last opened file: \(error)")
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

class AppDelegateHelper: ObservableObject {
    @Published var hasRestoredFile = false
}
