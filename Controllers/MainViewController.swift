import UIKit
import WebKit

class MainViewController: UIViewController {
    // MARK: - UI
    private let topToolbar = BrowserToolbar()
    private let bottomToolbar = BottomToolbar()
    private let tabsContainer = UIView()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Gestures
    private var swipeStartPoint: CGPoint = .zero
    private var swipeDirection: SwipeDirection = .none

    enum SwipeDirection {
        case none, left, right
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        setupGestures()
        setupObservers()
        loadInitialTab()
        applyTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        // Top Toolbar
        topToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topToolbar)

        // Bottom Toolbar
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomToolbar)

        // Tabs Container
        tabsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabsContainer)

        // Progress
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .clear
        progressView.isHidden = true
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        // Loading Indicator
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            topToolbar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topToolbar.heightAnchor.constraint(equalToConstant: 50),

            progressView.topAnchor.constraint(equalTo: topToolbar.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            tabsContainer.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            tabsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            bottomToolbar.topAnchor.constraint(equalTo: tabsContainer.bottomAnchor),
            bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func setupDelegates() {
        topToolbar.delegate = self
        bottomToolbar.delegate = self
    }

    private func setupGestures() {
        // Swipe для навигации
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)

        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)

        // Long press на кнопке назад/вперед для истории
        // (реализуется отдельно)
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .tabUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: .tabsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .themeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(readerModeChanged), name: .readerModeChanged, object: nil)
    }

    private func loadInitialTab() {
        let tab = TabManager.shared.createTab()
        addWebView(tab.webView)
        if let url = URL(string: "https://duckduckgo.com") {
            tab.load(url: url)
        }
        updateUI()
    }

    // MARK: - WebView Management
    private func addWebView(_ webView: WKWebView) {
        tabsContainer.subviews.forEach { $0.removeFromSuperview() }

        webView.translatesAutoresizingMaskIntoConstraints = false
        tabsContainer.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: tabsContainer.topAnchor),
            webView.leadingAnchor.constraint(equalTo: tabsContainer.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: tabsContainer.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: tabsContainer.bottomAnchor)
        ])

        // Добавляем наблюдатели
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        updateUI()
    }

    // MARK: - Observers
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch keyPath {
            case #keyPath(WKWebView.title):
                self.updateUI()
            case #keyPath(WKWebView.isLoading):
                self.updateUI()
            case #keyPath(WKWebView.estimatedProgress):
                self.updateProgress()
            default:
                break
            }
        }
    }

    // MARK: - UI Updates
    @objc private func updateUI() {
        guard let tab = TabManager.shared.currentTab else { return }

        topToolbar.update(
            url: tab.url?.absoluteString ?? "",
            title: tab.title,
            isLoading: tab.isLoading,
            canGoBack: tab.webView.canGoBack,
            canGoForward: tab.webView.canGoForward,
            isIncognito: TabManager.shared.isIncognito
        )

        bottomToolbar.update(tabCount: TabManager.shared.count)

        if let title = tab.webView.title, !title.isEmpty {
            navigationController?.title = title
        } else {
            navigationController?.title = "Awesome Browser"
        }
    }

    private func updateProgress() {
        guard let tab = TabManager.shared.currentTab else { return }

        progressView.isHidden = !tab.isLoading
        progressView.setProgress(tab.progress, animated: tab.isLoading)

        if tab.isLoading && tab.progress >= 1.0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.progressView.isHidden = true
                self.progressView.progress = 0.0
            }
        }
    }

    @objc private func applyTheme() {
        ThemeManager.shared.applyTheme()
    }

    @objc private func readerModeChanged() {
        guard let tab = TabManager.shared.currentTab else { return }
        topToolbar.setReaderModeAvailable(tab.readerModeAvailable)
    }

    // MARK: - Gestures
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            TabManager.shared.goForward()
        } else if gesture.direction == .right {
            TabManager.shared.goBack()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let webView = TabManager.shared.currentTab?.webView {
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
            webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        }
    }
}

// MARK: - BrowserToolbarDelegate
extension MainViewController: BrowserToolbarDelegate {
    func toolbarDidTapBack() { TabManager.shared.goBack() }
    func toolbarDidTapForward() { TabManager.shared.goForward() }
    func toolbarDidTapRefresh() { TabManager.shared.reloadCurrent() }
    func toolbarDidTapTabs() { showTabsController() }
    func toolbarDidTapStop() { TabManager.shared.stopLoading() }
    func toolbarDidTapReaderMode() { toggleReaderMode() }
    func toolbarDidTapIncognito() { toggleIncognito() }
    func toolbarDidSubmitURL(_ urlString: String) { loadURL(urlString) }

    private func showTabsController() {
        let tabsVC = TabsViewController()
        tabsVC.modalPresentationStyle = .pageSheet
        present(tabsVC, animated: true)
    }

    private func toggleReaderMode() {
        guard let tab = TabManager.shared.currentTab else { return }
        tab.readerModeActive.toggle()
        // В реальности здесь переключение на режим чтения
    }

    private func toggleIncognito() {
        TabManager.shared.toggleIncognito()
        if let webView = TabManager.shared.currentTab?.webView {
            addWebView(webView)
        }
        updateUI()
    }

    private func loadURL(_ urlString: String) {
        let tab = TabManager.shared.createTab(string: urlString)
        addWebView(tab.webView)
        updateUI()
    }
}

// MARK: - BottomToolbarDelegate
extension MainViewController: BottomToolbarDelegate {
    func bottomToolbarDidTapBack() { TabManager.shared.goBack() }
    func bottomToolbarDidTapForward() { TabManager.shared.goForward() }
    func bottomToolbarDidTapTabs() { showTabsController() }
    func bottomToolbarDidTapBookmarks() { showBookmarks() }
    func bottomToolbarDidTapHistory() { showHistory() }
    func bottomToolbarDidTapSettings() { showSettings() }
    func bottomToolbarDidTapShare() { shareCurrentPage() }

    private func showBookmarks() {
        let bookmarksVC = BookmarksViewController()
        let nav = UINavigationController(rootViewController: bookmarksVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func showHistory() {
        let historyVC = HistoryViewController()
        let nav = UINavigationController(rootViewController: historyVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func showSettings() {
        let settingsVC = SettingsViewController()
        let nav = UINavigationController(rootViewController: settingsVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    private func shareCurrentPage() {
        guard let url = TabManager.shared.currentTab?.url else { return }
        let items: [Any] = [url]
        let shareVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        shareVC.popoverPresentationController?.sourceView = view
        present(shareVC, animated: true)
    }
}
