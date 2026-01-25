import Foundation
import AppKit

@MainActor
class UpdateChecker: ObservableObject {
    static let shared = UpdateChecker()

    @Published var updateAvailable = false
    @Published var latestVersion: String?
    @Published var downloadURL: URL?
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0
    @Published var updateError: String?

    private let repoOwner = "faisalmirza"
    private let repoName = "vellum"

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    func checkForUpdates() {
        Task {
            await performCheck()
        }
    }

    private func performCheck() async {
        guard let url = URL(string: "https://api.github.com/repos/\(repoOwner)/\(repoName)/releases/latest") else {
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return
            }

            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tagName = json["tag_name"] as? String else {
                return
            }

            let latestVersion = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName

            // Find the zip asset download URL
            var zipURL: URL?
            if let assets = json["assets"] as? [[String: Any]] {
                for asset in assets {
                    if let name = asset["name"] as? String,
                       name.hasSuffix(".zip"),
                       let downloadURLString = asset["browser_download_url"] as? String {
                        zipURL = URL(string: downloadURLString)
                        break
                    }
                }
            }

            if isNewerVersion(latestVersion, than: currentVersion) {
                self.latestVersion = latestVersion
                self.downloadURL = zipURL
                self.updateAvailable = true
            }
        } catch {
            // Silently fail - update check is not critical
        }
    }

    private func isNewerVersion(_ new: String, than current: String) -> Bool {
        let newParts = new.split(separator: ".").compactMap { Int($0) }
        let currentParts = current.split(separator: ".").compactMap { Int($0) }

        for i in 0..<max(newParts.count, currentParts.count) {
            let newPart = i < newParts.count ? newParts[i] : 0
            let currentPart = i < currentParts.count ? currentParts[i] : 0

            if newPart > currentPart {
                return true
            } else if newPart < currentPart {
                return false
            }
        }
        return false
    }

    func performUpdate() {
        guard let downloadURL = downloadURL else {
            updateError = "No download URL available"
            return
        }

        isDownloading = true
        downloadProgress = 0
        updateError = nil

        Task {
            await downloadAndInstall(from: downloadURL)
        }
    }

    private func downloadAndInstall(from url: URL) async {
        let tempDir = FileManager.default.temporaryDirectory
        let zipPath = tempDir.appendingPathComponent("Vellum-update.zip")
        let extractPath = tempDir.appendingPathComponent("Vellum-update")

        do {
            // Clean up any previous update attempts
            try? FileManager.default.removeItem(at: zipPath)
            try? FileManager.default.removeItem(at: extractPath)

            // Download the zip file with progress
            let (localURL, _) = try await downloadWithProgress(from: url)

            // Move to our expected path
            try FileManager.default.moveItem(at: localURL, to: zipPath)

            downloadProgress = 0.7

            // Create extraction directory
            try FileManager.default.createDirectory(at: extractPath, withIntermediateDirectories: true)

            // Unzip
            let unzipProcess = Process()
            unzipProcess.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
            unzipProcess.arguments = ["-o", zipPath.path, "-d", extractPath.path]
            unzipProcess.standardOutput = FileHandle.nullDevice
            unzipProcess.standardError = FileHandle.nullDevice
            try unzipProcess.run()
            unzipProcess.waitUntilExit()

            guard unzipProcess.terminationStatus == 0 else {
                throw UpdateError.extractionFailed
            }

            downloadProgress = 0.85

            // Find the .app in extracted contents
            let contents = try FileManager.default.contentsOfDirectory(at: extractPath, includingPropertiesForKeys: nil)
            guard let appBundle = contents.first(where: { $0.pathExtension == "app" }) else {
                throw UpdateError.appNotFound
            }

            downloadProgress = 0.9

            // Get current app path
            guard let currentAppPath = Bundle.main.bundlePath as String? else {
                throw UpdateError.installationFailed
            }
            let currentAppURL = URL(fileURLWithPath: currentAppPath)

            // Create update script that will run after app quits
            // Uses osascript for admin privileges if needed
            let scriptPath = tempDir.appendingPathComponent("vellum-update.sh")
            let script = """
            #!/bin/bash
            sleep 1

            # Try without admin first
            if rm -rf "\(currentAppURL.path)" 2>/dev/null && cp -R "\(appBundle.path)" "\(currentAppURL.path)" 2>/dev/null; then
                open "\(currentAppURL.path)"
            else
                # Need admin privileges - use AppleScript
                osascript -e 'do shell script "rm -rf \\"\(currentAppURL.path)\\" && cp -R \\"\(appBundle.path)\\" \\"\(currentAppURL.path)\\"" with administrator privileges'
                open "\(currentAppURL.path)"
            fi

            rm -rf "\(extractPath.path)"
            rm -f "\(zipPath.path)"
            rm -f "\(scriptPath.path)"
            """

            try script.write(to: scriptPath, atomically: true, encoding: .utf8)

            // Make script executable
            let chmodProcess = Process()
            chmodProcess.executableURL = URL(fileURLWithPath: "/bin/chmod")
            chmodProcess.arguments = ["+x", scriptPath.path]
            try chmodProcess.run()
            chmodProcess.waitUntilExit()

            downloadProgress = 1.0

            // Launch the update script and quit
            let updateProcess = Process()
            updateProcess.executableURL = URL(fileURLWithPath: "/bin/bash")
            updateProcess.arguments = [scriptPath.path]
            try updateProcess.run()

            // Quit the app to allow update
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NSApplication.shared.terminate(nil)
            }

        } catch {
            isDownloading = false
            updateError = error.localizedDescription
        }
    }

    private func downloadWithProgress(from url: URL) async throws -> (URL, URLResponse) {
        let delegate = DownloadDelegate { [weak self] progress in
            Task { @MainActor in
                self?.downloadProgress = progress * 0.7
            }
        }

        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let (localURL, response) = try await session.download(from: url)

        // Move from temp location to our controlled path
        let destURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".zip")
        try FileManager.default.moveItem(at: localURL, to: destURL)

        return (destURL, response)
    }

    func dismissUpdate() {
        updateAvailable = false
        isDownloading = false
        downloadProgress = 0
        updateError = nil
    }
}

private class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    let progressHandler: (Double) -> Void

    init(progressHandler: @escaping (Double) -> Void) {
        self.progressHandler = progressHandler
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // Handled by async/await
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        progressHandler(progress)
    }
}

enum UpdateError: LocalizedError {
    case extractionFailed
    case appNotFound
    case installationFailed

    var errorDescription: String? {
        switch self {
        case .extractionFailed:
            return "Failed to extract update"
        case .appNotFound:
            return "App not found in update"
        case .installationFailed:
            return "Failed to install update"
        }
    }
}
