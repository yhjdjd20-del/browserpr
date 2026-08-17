import Foundation

struct HistoryItem: Codable {
    let id = UUID()
    let title: String
    let url: String
    let date: Date
    let visits: Int
}
