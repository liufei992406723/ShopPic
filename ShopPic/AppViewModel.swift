import SwiftUI

struct HistoryEntry: Identifiable, Codable {
    let id = UUID()
    let platform: Platform
    let date: Date
    let thumbnailData: Data?

    var thumbnail: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
}

@MainActor
final class AppViewModel: ObservableObject {
    @Published var sharedImage: UIImage?
    @Published var recentPlatforms: [Platform] = []
    @Published var searchHistory: [HistoryEntry] = []

    private let maxRecentPlatforms = 5
    private let maxHistoryEntries = 50
    private let historyKey = "com.shoppic.searchHistory"
    private let recentKey = "com.shoppic.recentPlatforms"

    init() {
        loadHistory()
        loadRecentPlatforms()
    }

    func loadSharedImage() {
        sharedImage = AppGroupConstants.loadImage()
    }

    func clearImage() {
        sharedImage = nil
        AppGroupConstants.deleteImage()
    }

    func recordPlatformUse(_ platform: Platform) {
        recentPlatforms.removeAll { $0 == platform }
        recentPlatforms.insert(platform, at: 0)
        if recentPlatforms.count > maxRecentPlatforms {
            recentPlatforms = Array(recentPlatforms.prefix(maxRecentPlatforms))
        }
        persistRecentPlatforms()
    }

    func addHistory(platform: Platform, image: UIImage?) {
        let thumbnailData: Data? = {
            guard let image else { return nil }
            let resized = resizeForThumbnail(image)
            return resized.jpegData(compressionQuality: 0.3)
        }()
        let entry = HistoryEntry(platform: platform, date: Date(), thumbnailData: thumbnailData)
        searchHistory.insert(entry, at: 0)
        if searchHistory.count > maxHistoryEntries {
            searchHistory = Array(searchHistory.prefix(maxHistoryEntries))
        }
        persistHistory()
    }

    private func resizeForThumbnail(_ image: UIImage) -> UIImage {
        let size = image.size
        let maxDim: CGFloat = 120
        let scale = min(maxDim / max(size.width, size.height), 1.0)
        guard scale < 1.0 else { return image }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private func persistHistory() {
        guard let data = try? JSONEncoder().encode(searchHistory) else { return }
        UserDefaults.standard.set(data, forKey: historyKey)
    }

    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([HistoryEntry].self, from: data)
        else { return }
        searchHistory = history
    }

    private func persistRecentPlatforms() {
        guard let data = try? JSONEncoder().encode(recentPlatforms) else { return }
        UserDefaults.standard.set(data, forKey: recentKey)
    }

    private func loadRecentPlatforms() {
        guard let data = UserDefaults.standard.data(forKey: recentKey),
              let recent = try? JSONDecoder().decode([Platform].self, from: data)
        else { return }
        recentPlatforms = recent
    }
}
