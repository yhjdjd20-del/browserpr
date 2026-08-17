import Foundation
import UIKit

class TabManager {
    static let shared = TabManager()

    private(set) var tabs: [Tab] = []
    private(set) var currentTabIndex: Int = 0
    private(set) var incognitoTabs: [Tab] = []
    private(set) var currentIncognitoIndex: Int = 0
    var isIncognito: Bool = false

    var currentTab: Tab? {
        let list = isIncognito ? incognitoTabs : tabs
        let index = isIncognito ? currentIncognitoIndex : currentTabIndex
        guard list.indices.contains(index) else { return nil }
        return list[index]
    }

    var allTabs: [Tab] {
        return isIncognito ? incognitoTabs : tabs
    }

    var count: Int {
        return allTabs.count
    }

    func createTab(url: URL? = nil) -> Tab {
        let tab = Tab(url: url, incognito: isIncognito)
        if isIncognito {
            incognitoTabs.append(tab)
            currentIncognitoIndex = incognitoTabs.count - 1
        } else {
            tabs.append(tab)
            currentTabIndex = tabs.count - 1
        }
        NotificationCenter.default.post(name: .tabsChanged, object: nil)
        return tab
    }

    func createTab(string: String) -> Tab {
        let tab = createTab()
        tab.load(string: string)
        return tab
    }

    func closeTab(at index: Int) {
        if isIncognito {
            guard incognitoTabs.indices.contains(index) else { return }
            incognitoTabs.remove(at: index)
            if incognitoTabs.isEmpty {
                createTab()
            }
            if currentIncognitoIndex >= incognitoTabs.count {
                currentIncognitoIndex = incognitoTabs.count - 1
            }
        } else {
            guard tabs.indices.contains(index) else { return }
            tabs.remove(at: index)
            if tabs.isEmpty {
                createTab()
            }
            if currentTabIndex >= tabs.count {
                currentTabIndex = tabs.count - 1
            }
        }
        NotificationCenter.default.post(name: .tabsChanged, object: nil)
    }

    func switchTab(at index: Int) {
        if isIncognito {
            guard incognitoTabs.indices.contains(index) else { return }
            currentIncognitoIndex = index
        } else {
            guard tabs.indices.contains(index) else { return }
            currentTabIndex = index
        }
        NotificationCenter.default.post(name: .tabsChanged, object: nil)
    }

    func closeAll() {
        if isIncognito {
            incognitoTabs.removeAll()
            createTab()
            currentIncognitoIndex = 0
        } else {
            tabs.removeAll()
            createTab()
            currentTabIndex = 0
        }
        NotificationCenter.default.post(name: .tabsChanged, object: nil)
    }

    func toggleIncognito() {
        isIncognito.toggle()
        if isIncognito && incognitoTabs.isEmpty {
            createTab()
        }
        NotificationCenter.default.post(name: .tabsChanged, object: nil)
    }

    func reloadCurrent() { currentTab?.reload() }
    func goBack() { currentTab?.goBack() }
    func goForward() { currentTab?.goForward() }
    func stopLoading() { currentTab?.stopLoading() }
}

extension Notification.Name {
    static let tabsChanged = Notification.Name("tabsChanged")
}
