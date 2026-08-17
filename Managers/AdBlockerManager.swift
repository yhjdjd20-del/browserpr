import Foundation

class AdBlockerManager {
    static let shared = AdBlockerManager()

    private let adDomains: Set<String> = [
        "doubleclick.net",
        "googleadservices.com",
        "googlesyndication.com",
        "google-analytics.com",
        "facebook.com/tr",
        "facebook.com/ads",
        "adnxs.com",
        "adsrvr.org",
        "adservice.google.com",
        "pagead2.googlesyndication.com",
        "pubads.g.doubleclick.net",
        "tpc.googlesyndication.com",
        "ad.doubleclick.net",
        "googleads.g.doubleclick.net",
        "adservice.google.com",
        "criteo.com",
        "criteo.net",
        "taboola.com",
        "outbrain.com",
        "yieldmo.com",
        "sharethrough.com",
        "amazon-adsystem.com",
        "casalemedia.com",
        "contextweb.com",
        "indexexchange.com",
        "openx.net",
        "pubmatic.com",
        "rubiconproject.com",
        "sovrn.com",
        "spotxchange.com",
        "yieldmanager.com",
        "yahoo.com/ads",
        "bing.com/ads",
        "msn.com/ads"
    ]

    private let adExtensions: Set<String> = [
        ".ad", ".ads", ".advert", ".advertisement"
    ]

    func shouldBlock(url: URL) -> Bool {
        guard let host = url.host?.lowercased() else { return false }

        // Проверка по домену
        for domain in adDomains {
            if host.contains(domain) {
                return true
            }
        }

        let path = url.path.lowercased()
        for ext in adExtensions {
            if path.hasSuffix(ext) {
                return true
            }
        }

        return false
    }
}
