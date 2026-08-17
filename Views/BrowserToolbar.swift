import UIKit

protocol BrowserToolbarDelegate: AnyObject {
    func toolbarDidTapBack()
    func toolbarDidTapForward()
    func toolbarDidTapRefresh()
    func toolbarDidTapTabs()
    func toolbarDidTapStop()
    func toolbarDidTapReaderMode()
    func toolbarDidTapIncognito()
    func toolbarDidSubmitURL(_ urlString: String)
}

class BrowserToolbar: UIView {
    weak var delegate: BrowserToolbarDelegate?

    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let refreshButton = UIButton(type: .system)
    private let tabsButton = UIButton(type: .system)
    private let readerButton = UIButton(type: .system)
    private let incognitoButton = UIButton(type: .system)
    private let urlTextField = UITextField()
    private let containerView = UIView()
    private var readerAvailable: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = UIColor.systemGray6

        // Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        containerView.layer.borderWidth = 0.5
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // Buttons
        setupButton(backButton, image: "chevron.left", action: #selector(backTapped))
        setupButton(forwardButton, image: "chevron.right", action: #selector(forwardTapped))
        setupButton(refreshButton, image: "arrow.clockwise", action: #selector(refreshTapped))
        setupButton(tabsButton, image: "square.on.square", action: #selector(tabsTapped))
        setupButton(readerButton, image: "doc.text.magnifyingglass", action: #selector(readerTapped))
        setupButton(incognitoButton, image: "theatermasks", action: #selector(incognitoTapped))
        readerButton.isEnabled = false
        readerButton.tintColor = .systemGray3

        // URL
        urlTextField.placeholder = "Search or enter URL"
        urlTextField.font = .systemFont(ofSize: 14)
        urlTextField.clearButtonMode = .whileEditing
        urlTextField.autocapitalizationType = .none
        urlTextField.autocorrectionType = .no
        urlTextField.returnKeyType = .go
        urlTextField.delegate = self
        urlTextField.translatesAutoresizingMaskIntoConstraints = false

        // Layout
        [backButton, forwardButton, containerView, refreshButton, readerButton, incognitoButton, tabsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        containerView.addSubview(urlTextField)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 30),

            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            forwardButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            forwardButton.widthAnchor.constraint(equalToConstant: 30),

            containerView.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor, constant: 8),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 36),

            refreshButton.leadingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8),
            refreshButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            refreshButton.widthAnchor.constraint(equalToConstant: 30),

            readerButton.leadingAnchor.constraint(equalTo: refreshButton.trailingAnchor, constant: 4),
            readerButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            readerButton.widthAnchor.constraint(equalToConstant: 30),

            incognitoButton.leadingAnchor.constraint(equalTo: readerButton.trailingAnchor, constant: 4),
            incognitoButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            incognitoButton.widthAnchor.constraint(equalToConstant: 30),

            tabsButton.leadingAnchor.constraint(equalTo: incognitoButton.trailingAnchor, constant: 4),
            tabsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            tabsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabsButton.widthAnchor.constraint(equalToConstant: 30),

            urlTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            urlTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            urlTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

    private func setupButton(_ button: UIButton, image: String, action: Selector) {
        button.setImage(UIImage(systemName: image), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc private func backTapped() { delegate?.toolbarDidTapBack() }
    @objc private func forwardTapped() { delegate?.toolbarDidTapForward() }
    @objc private func refreshTapped() { delegate?.toolbarDidTapRefresh() }
    @objc private func tabsTapped() { delegate?.toolbarDidTapTabs() }
    @objc private func readerTapped() { delegate?.toolbarDidTapReaderMode() }
    @objc private func incognitoTapped() { delegate?.toolbarDidTapIncognito() }

    func update(url: String, title: String, isLoading: Bool, canGoBack: Bool, canGoForward: Bool, isIncognito: Bool) {
        urlTextField.text = url.isEmpty ? title : url

        backButton.isEnabled = canGoBack
        backButton.tintColor = canGoBack ? .label : .systemGray3

        forwardButton.isEnabled = canGoForward
        forwardButton.tintColor = canGoForward ? .label : .systemGray3

        let icon = isLoading ? "stop.fill" : "arrow.clockwise"
        refreshButton.setImage(UIImage(systemName: icon), for: .normal)
        refreshButton.removeTarget(nil, action: nil, for: .allEvents)
        refreshButton.addTarget(self, action: isLoading ? #selector(stopTapped) : #selector(refreshTapped), for: .touchUpInside)

        incognitoButton.tintColor = isIncognito ? .systemPurple : .systemGray3
        incognitoButton.backgroundColor = isIncognito ? .systemPurple.withAlphaComponent(0.2) : .clear
        incognitoButton.layer.cornerRadius = 4
    }

    func setReaderModeAvailable(_ available: Bool) {
        readerAvailable = available
        readerButton.isEnabled = available
        readerButton.tintColor = available ? .label : .systemGray3
    }

    @objc private func stopTapped() {
        delegate?.toolbarDidTapStop()
    }
}

// MARK: - UITextFieldDelegate
extension BrowserToolbar: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text, !text.isEmpty else { return false }
        delegate?.toolbarDidSubmitURL(text)
        textField.resignFirstResponder()
        return true
    }
}
