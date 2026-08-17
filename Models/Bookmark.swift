import Foundation

struct Bookmark: Codable {
    let id = UUID()
    let title: String
    let url: String
    let dateAdded: Date
    var folder: String?
    var icon: String?
}

struct BookmarkFolder: Codable {
    let id = UUID()
    let name: String
    let bookmarks: [Bookmark]
}
