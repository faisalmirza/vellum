import AppKit

class DocumentController: NSDocumentController {
    private let lastDirectoryKey = "LastOpenDirectory"

    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func runModalOpenPanel(_ openPanel: NSOpenPanel, forTypes types: [String]?) -> Int {
        if let lastDirectory = UserDefaults.standard.url(forKey: lastDirectoryKey) {
            openPanel.directoryURL = lastDirectory
        }

        let result = super.runModalOpenPanel(openPanel, forTypes: types)

        if result == NSApplication.ModalResponse.OK.rawValue,
           let url = openPanel.url {
            let directory = url.deletingLastPathComponent()
            UserDefaults.standard.set(directory, forKey: lastDirectoryKey)
        }

        return result
    }

    override func noteNewRecentDocumentURL(_ url: URL) {
        super.noteNewRecentDocumentURL(url)
        let directory = url.deletingLastPathComponent()
        UserDefaults.standard.set(directory, forKey: lastDirectoryKey)
    }
}
