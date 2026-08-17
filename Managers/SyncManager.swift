import Foundation

class SyncManager {
    static let shared = SyncManager()

    private let userDefaults = UserDefaults.standard
    private let syncKey = "sync_enabled"

    var isEnabled: Bool {
        get { userDefaults.bool(forKey: syncKey) }
        set { userDefaults.set(newValue, forKey: syncKey) }
    }

    func syncBookmarks() {
        guard isEnabled else { return }
        // Здесь можно добавить синхронизацию с iCloud, Firebase и т.д.
        print("📡 Syncing bookmarks...")
    }

    func syncHistory() {
        guard isEnabled else { return }
        print("📡 Syncing history...")
    }

    func syncPasswords() {
        guard isEnabled else { return }
        print("📡 Syncing passwords...")
    }

    func syncAll() {
        syncBookmarks()
        syncHistory()
        syncPasswords()
    }
}
