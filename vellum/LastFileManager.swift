import Foundation

/// Manages persistence of the last opened file path using UserDefaults
/// Uses security-scoped bookmarks for sandboxed app support
class LastFileManager {
    static let shared = LastFileManager()
    
    private let lastFileBookmarkKey = "LastOpenedFileBookmark"
    
    private init() {}
    
    /// Saves the file bookmark to UserDefaults
    func saveLastOpenedFile(_ url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: lastFileBookmarkKey)
        } catch {
            print("Failed to create bookmark: \(error)")
        }
    }
    
    /// Retrieves the last opened file URL if it exists and is accessible
    func getLastOpenedFile() -> URL? {
        guard let bookmarkData = UserDefaults.standard.data(forKey: lastFileBookmarkKey) else {
            return nil
        }
        
        do {
            var isStale = false
            let url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            
            // Start accessing security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                return nil
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            // Check if file exists
            guard FileManager.default.fileExists(atPath: url.path()) else {
                return nil
            }
            
            // If bookmark is stale, update it
            if isStale {
                saveLastOpenedFile(url)
            }
            
            return url
        } catch {
            print("Failed to resolve bookmark: \(error)")
            return nil
        }
    }
}
