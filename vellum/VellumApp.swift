import SwiftUI

// Helper class to manage launch observer lifecycle
class LaunchObserver {
    private var observer: NSObjectProtocol?
    
    func setupObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: NSApplication.didFinishLaunchingNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            VellumApp.restoreLastOpenedFile()
            self?.removeObserver()
        }
    }
    
    private func removeObserver() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }
    
    deinit {
        removeObserver()
    }
}

@main
struct VellumApp: App {
    @StateObject private var updateChecker = UpdateChecker.shared
    private let launchObserver = LaunchObserver()

    init() {
        // Check for updates on launch
        UpdateChecker.shared.checkForUpdates()
        
        // Setup last file restoration observer
        launchObserver.setupObserver()
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
    
    private static func restoreLastOpenedFile() {
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
