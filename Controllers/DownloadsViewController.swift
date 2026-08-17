import UIKit

class DownloadsViewController: UIViewController {
    private let tableView = UITableView()
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupObservers()
        updateUI()
    }

    private func setupUI() {
        title = "Downloads"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear",
            style: .plain,
            target: self,
            action: #selector(clearTapped)
        )

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DownloadCell.self, forCellReuseIdentifier: "DownloadCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        emptyLabel.text = "No downloads yet"
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.font = .systemFont(ofSize: 18)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupObservers() {
        DownloadManager.shared.onUpdate = { [weak self] in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }
    }

    private func updateUI() {
        let downloads = DownloadManager.shared.getDownloads()
        tableView.isHidden = downloads.isEmpty
        emptyLabel.isHidden = !downloads.isEmpty
        tableView.reloadData()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func clearTapped() {
        DownloadManager.shared.clearCompleted()
    }
}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DownloadManager.shared.getDownloads().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell", for: indexPath) as! DownloadCell
        let download = DownloadManager.shared.getDownloads()[indexPath.item]
        cell.configure(with: download)
        cell.onCancel = { [weak self] in
            self?.cancelDownload(at: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let download = DownloadManager.shared.getDownloads()[indexPath.item]
        if case .completed(let url) = download.status {
            DownloadManager.shared.openFile(at: url)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DownloadManager.shared.cancelDownload(at: indexPath.item)
            updateUI()
        }
    }

    private func cancelDownload(at indexPath: IndexPath) {
        DownloadManager.shared.cancelDownload(at: indexPath.item)
        updateUI()
    }
}

// MARK: - DownloadCell
class DownloadCell: UITableViewCell {
    private let iconView = UIImageView()
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let cancelButton = UIButton(type: .system)

    var onCancel: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        iconView.image = UIImage(systemName: "arrow.down.circle.fill")
        iconView.tintColor = .systemBlue
        iconView.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        nameLabel.numberOfLines = 1
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        statusLabel.font = .systemFont(ofSize: 13)
        statusLabel.textColor = .secondaryLabel
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        progressView.progressTintColor = .systemBlue
        progressView.translatesAutoresizingMaskIntoConstraints = false

        cancelButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        cancelButton.tintColor = .systemRed
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(progressView)
        contentView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 30),
            iconView.heightAnchor.constraint(equalToConstant: 30),

            nameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8),

            statusLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            statusLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            progressView.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            progressView.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cancelButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 30),
            cancelButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    func configure(with download: DownloadItem) {
        nameLabel.text = download.filename

        switch download.status {
        case .downloading:
            statusLabel.text = "Downloading..."
            progressView.isHidden = false
            progressView.setProgress(download.progress, animated: true)
            cancelButton.isHidden = false
            iconView.tintColor = .systemBlue
            iconView.startRotating()

        case .completed(let url):
            statusLabel.text = "Completed ✅"
            progressView.isHidden = true
            cancelButton.isHidden = true
            iconView.tintColor = .systemGreen
            iconView.stopRotating()

        case .failed(let error):
            statusLabel.text = "Failed: \(error)"
            progressView.isHidden = true
            cancelButton.isHidden = true
            iconView.tintColor = .systemRed
            iconView.stopRotating()

        case .cancelled:
            statusLabel.text = "Cancelled"
            progressView.isHidden = true
            cancelButton.isHidden = true
            iconView.tintColor = .systemGray
            iconView.stopRotating()
        }
    }

    @objc private func cancelTapped() {
        onCancel?()
    }
}

extension UIImageView {
    func startRotating() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.duration = 1.0
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        layer.add(animation, forKey: "rotation")
    }

    func stopRotating() {
        layer.removeAnimation(forKey: "rotation")
    }
}
