import UIKit
import WebKit

class DownloadManager: NSObject {
    static let shared = DownloadManager()

    private var downloads: [DownloadItem] = []
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    var onUpdate: (() -> Void)?

    func startDownload(from url: URL, webView: WKWebView? = nil) {
        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
            guard let self = self else { return }

            if let error = error {
                self.updateDownloadStatus(url: url, status: .failed(error.localizedDescription))
                return
            }

            guard let tempURL = tempURL else {
                self.updateDownloadStatus(url: url, status: .failed("No file"))
                return
            }

            let suggestedName = response?.suggestedFilename ?? url.lastPathComponent
            let destURL = self.documentsPath.appendingPathComponent(suggestedName)

            do {
                if FileManager.default.fileExists(atPath: destURL.path) {
                    try FileManager.default.removeItem(at: destURL)
                }
                try FileManager.default.moveItem(at: tempURL, to: destURL)

                // Уведомление
                self.updateDownloadStatus(url: url, status: .completed(destURL))

                NotificationCenter.default.post(name: .downloadCompleted, object: destURL)
            } catch {
                self.updateDownloadStatus(url: url, status: .failed(error.localizedDescription))
            }
        }

        // Добавляем в список
        let item = DownloadItem(
            url: url,
            filename: url.lastPathComponent,
            progress: 0,
            status: .downloading,
            task: task
        )
        downloads.append(item)
        onUpdate?()

        // Прогресс через KVO
        let observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.updateProgress(url: url, progress: Float(progress.fractionCompleted))
            }
        }

        // Сохраняем observation
        item.observation = observation
        task.resume()
    }

    func startDownload(from string: String, webView: WKWebView? = nil) {
        guard let url = URL(string: string) else { return }
        startDownload(from: url, webView: webView)
    }

    private func updateProgress(url: URL, progress: Float) {
        if let index = downloads.firstIndex(where: { $0.url == url }) {
            downloads[index].progress = progress
            onUpdate?()
        }
    }

    private func updateDownloadStatus(url: URL, status: DownloadStatus) {
        if let index = downloads.firstIndex(where: { $0.url == url }) {
            downloads[index].status = status
            onUpdate?()
        }
    }

    func getDownloads() -> [DownloadItem] {
        return downloads
    }

    func cancelDownload(at index: Int) {
        guard downloads.indices.contains(index) else { return }
        downloads[index].task?.cancel()
        downloads[index].status = .cancelled
        onUpdate?()
    }

    func clearCompleted() {
        downloads.removeAll { $0.status.isCompleted }
        onUpdate?()
    }

    func openFile(at url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Модели
enum DownloadStatus {
    case downloading
    case completed(URL)
    case failed(String)
    case cancelled

    var isCompleted: Bool {
        if case .completed = self { return true }
        return false
    }

    var isActive: Bool {
        if case .downloading = self { return true }
        return false
    }
}

class DownloadItem {
    let url: URL
    let filename: String
    var progress: Float
    var status: DownloadStatus
    var task: URLSessionDownloadTask?
    var observation: NSKeyValueObservation?

    init(url: URL, filename: String, progress: Float, status: DownloadStatus, task: URLSessionDownloadTask?) {
        self.url = url
        self.filename = filename
        self.progress = progress
        self.status = status
        self.task = task
    }
}

extension Notification.Name {
    static let downloadCompleted = Notification.Name("downloadCompleted")
}
