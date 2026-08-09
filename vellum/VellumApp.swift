import SwiftUI

/// Vellum - A fast markdown viewer for macOS with QuickLook extension
///
/// The self-update machinery is compiled out of App Store builds, which set
/// the APP_STORE flag in the AppStore configuration. Developer ID builds
/// (Release, shipped via Homebrew) leave it undefined and keep the updater.
@main
struct VellumApp: App {
    #if !APP_STORE
    @StateObject private var updateChecker = UpdateChecker.shared
    #endif

    init() {
        #if !APP_STORE
        // Check for updates on launch
        UpdateChecker.shared.checkForUpdates()
        #endif
    }

    var body: some Scene {
        DocumentGroup(newDocument: MarkdownDocument()) { file in
            ContentView(document: file.$document)
                #if !APP_STORE
                .environmentObject(updateChecker)
                #endif
        }
        .commands {
            CommandGroup(replacing: .help) { }
            #if !APP_STORE
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
            #endif
        }
    }

    #if !APP_STORE
    private func showUpToDateAlert() {
        let alert = NSAlert()
        alert.messageText = "You're up to date!"
        alert.informativeText = "Vellum \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") is the latest version."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    #endif
}
