import Foundation

struct Settings: Codable {
    var defaultSearchEngine: SearchEngine = .duckduckgo
    var theme: Theme = .system
    var adBlockerEnabled: Bool = true
    var javascriptEnabled: Bool = true
    var popupBlockerEnabled: Bool = true
    var readerModeEnabled: Bool = true
    var autoOpenDownloads: Bool = false
    var savePasswords: Bool = true
    var privateBrowsing: Bool = false

    enum SearchEngine: String, Codable, CaseIterable {
        case google = "Google"
        case duckduckgo = "DuckDuckGo"
        case bing = "Bing"
        case yahoo = "Yahoo"
        case ecosia = "Ecosia"
        case startpage = "Startpage"

        var url: String {
            switch self {
            case .google: return "https://www.google.com/search?q="
            case .duckduckgo: return "https://duckduckgo.com/?q="
            case .bing: return "https://www.bing.com/search?q="
            case .yahoo: return "https://search.yahoo.com/search?p="
            case .ecosia: return "https://www.ecosia.org/search?q="
            case .startpage: return "https://www.startpage.com/do/dsearch?query="
            }
        }
    }

    enum Theme: String, Codable, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
}
