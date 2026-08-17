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
        readerButton.tintColor
