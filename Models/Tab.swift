import Foundation
import WebKit

class Tab: NSObject {
    var id: UUID
    var title: String
    var url: URL?
    var webView: WKWebView
    var isLoading: Bool = false
    var progress: Float = 0.0
    var isIncognito: Bool = false
    var lastVisited: Date = Date()
    var screenshot: UIImage?
    var readerModeAvailable: Bool = false
    var readerModeActive: Bool = false

    init(url: URL? = nil, incognito: Bool = false) {
        self.id = UUID()
        self.url = url
        self.title = "New Tab"
        self.isIncognito = incognito

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        // Инкогнито
        if incognito {
            config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }

        self.webView = WKWebView(frame: .zero, configuration: config)
        super.init()

        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)

        if let url = url {
            load(url: url)
        }
    }

    func load(url: URL) {
        self.url = url
        webView.load(URLRequest(url: url))
    }

    func load(string: String) {
        var urlString = string
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        if let url = URL(string: urlString) {
            load(url: url)
        } else if let url = URL(string: "https://duckduckgo.com/?q=\(string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            load(url: url)
        }
    }

    func reload() { webView.reload() }
    func goBack() { webView.goBack() }
    func goForward() { webView.goForward() }
    func stopLoading() { webView.stopLoading() }

    func takeScreenshot() {
        let config = WKSnapshotConfiguration()
        webView.takeSnapshot(with: config) { [weak self] image, error in
            if let image = image {
                self?.screenshot = image
            }
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath {
        case #keyPath(WKWebView.title):
            if let newTitle = change?[.newKey] as? String, !newTitle.isEmpty {
                self.title = newTitle
            }
        case #keyPath(WKWebView.isLoading):
            self.isLoading = webView.isLoading
            if !isLoading {
                takeScreenshot()
            }
        case #keyPath(WKWebView.estimatedProgress):
            self.progress = Float(webView.estimatedProgress)
        case #keyPath(WKWebView.url):
            self.url = webView.url
        default:
            break
        }
        NotificationCenter.default.post(name: .tabUpdated, object: self)
    }

    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.url))
    }
}

// MARK: - WKNavigationDelegate
extension Tab: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        url = webView.url
        title = webView.title ?? "New Tab"
        // Проверка на Reader Mode
        if let url = url, !isIncognito {
            let html = """
            (function() {
                let article = document.querySelector('article');
                let main = document.querySelector('main');
                let content = document.querySelector('.content, .post-content, .entry-content');
                return !!(article || main || content);
            })();
            """
            webView.evaluateJavaScript(html) { [weak self] result, _ in
                self?.readerModeAvailable = (result as? Bool) ?? false
                NotificationCenter.default.post(name: .readerModeChanged, object: self)
            }
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Navigation error: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Provisional error: \(error.localizedDescription)")
    }

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Блокировка рекламы через AdBlockerManager
        if let url = navigationAction.request.url {
            if AdBlockerManager.shared.shouldBlock(url: url) {
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension Tab: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: webView.title, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in textField.text = defaultText }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
    }
}

extension Notification.Name {
    static let tabUpdated = Notification.Name("tabUpdated")
    static let readerModeChanged = Notification.Name("readerModeChanged")
}
