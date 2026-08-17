import UIKit

class ThemeManager {
    static let shared = ThemeManager()

    var currentTheme: Settings.Theme = .system {
        didSet {
            applyTheme()
        }
    }

    func applyTheme() {
        let isDark: Bool
        switch currentTheme {
        case .light: isDark = false
        case .dark: isDark = true
        case .system: isDark = UITraitCollection.current.userInterfaceStyle == .dark
        }

        // Применение темы ко всему приложению
        if isDark {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }

        NotificationCenter.default.post(name: .themeChanged, object: nil)
    }
}

extension Notification.Name {
    static let themeChanged = Notification.Name("themeChanged")
}
