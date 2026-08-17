import UIKit

protocol BottomToolbarDelegate: AnyObject {
    func bottomToolbarDidTapBack()
    func bottomToolbarDidTapForward()
    func bottomToolbarDidTapTabs()
    func bottomToolbarDidTapBookmarks()
    func bottomToolbarDidTapHistory()
    func bottomToolbarDidTapSettings()
    func bottomToolbarDidTapShare()
}

class BottomToolbar: UIView {
    weak var delegate: BottomToolbarDelegate?

    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let tabsButton = UIButton(type: .system)
    private let bookmarksButton = UIButton(type: .system)
    private let historyButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    private let shareButton = UIButton(type: .system)

    private let tabCountLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        let separator = UIView()
        separator.backgroundColor = UIColor.systemGray4
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)

        let buttons: [(UIButton, String, Selector)] = [
            (backButton, "chevron.left", #selector(backTapped)),
            (forwardButton, "chevron.right", #selector(forwardTapped)),
            (bookmarksButton, "bookmark", #selector(bookmarksTapped)),
            (tabsButton, "square.on.square", #selector(tabsTapped)),
            (historyButton, "clock", #selector(historyTapped)),
            (settingsButton, "gear", #selector(settingsTapped)),
            (shareButton, "square.and.arrow.up", #selector(shareTapped))
        ]

        for (btn, icon, action) in buttons {
            btn.setImage(UIImage(systemName: icon), for: .normal)
            btn.tintColor = .label
            btn.addTarget(self, action: action, for: .touchUpInside)
            btn.translatesAutoresizingMaskIntoConstraints = false
            addSubview(btn)
        }

        // Tab Count
        tabCountLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        tabCountLabel.textColor = .white
        tabCountLabel.backgroundColor = .systemBlue
        tabCountLabel.textAlignment = .center
        tabCountLabel.layer.cornerRadius = 8
        tabCountLabel.clipsToBounds = true
        tabCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabCountLabel)

        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),

            // Равномерное распределение
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            forwardButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            bookmarksButton.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor, constant: 12),
            bookmarksButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            tabsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            tabsButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            historyButton.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -12),
            historyButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            settingsButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -12),
            settingsButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            shareButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            shareButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            tabCountLabel.topAnchor.constraint(equalTo: tabsButton.topAnchor, constant: -4),
            tabCountLabel.trailingAnchor.constraint(equalTo: tabsButton.trailingAnchor, constant: 8),
            tabCountLabel.widthAnchor.constraint(equalToConstant: 16),
            tabCountLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    @objc private func backTapped() { delegate?.bottomToolbarDidTapBack() }
    @objc private func forwardTapped() { delegate?.bottomToolbarDidTapForward() }
    @objc private func tabsTapped() { delegate?.bottomToolbarDidTapTabs() }
    @objc private func bookmarksTapped() { delegate?.bottomToolbarDidTapBookmarks() }
    @objc private func historyTapped() { delegate?.bottomToolbarDidTapHistory() }
    @objc private func settingsTapped() { delegate?.bottomToolbarDidTapSettings() }
    @objc private func shareTapped() { delegate?.bottomToolbarDidTapShare() }

    func update(tabCount: Int) {
        tabCountLabel.text = "\(tabCount)"
        tabCountLabel.isHidden = tabCount <= 1
    }
}
