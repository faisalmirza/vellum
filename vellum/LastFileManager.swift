import Foundation

/// Manages persistence of the last opened file path using UserDefaults
class LastFileManager {
    static let shared = LastFileManager()
    
    private let lastFilePathKey = "LastOpenedFilePath"
    
    private init() {}
    
    /// Saves the file path to UserDefaults
    func saveLastOpenedFile(_ url: URL) {
        UserDefaults.standard.set(url.path, forKey: lastFilePathKey)
    }
    
    /// Retrieves the last opened file URL if it exists and is accessible
    func getLastOpenedFile() -> URL? {
        guard let path = UserDefaults.standard.string(forKey: lastFilePathKey) else {
            return nil
        }
        
        let url = URL(fileURLWithPath: path)
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: path) else {
            return nil
        }
        
        return url
    }
}
