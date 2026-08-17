import Foundation

struct PasswordItem: Codable {
    let id = UUID()
    let website: String
    let username: String
    let password: String
    let dateAdded: Date
    let lastUsed: Date?
}
