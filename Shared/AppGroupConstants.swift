import UIKit

enum AppGroupConstants {
    static let appGroupID = "group.com.shoppic.app"

    static var containerURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        )
    }

    static var sharedImageURL: URL? {
        containerURL?.appendingPathComponent("shared_search_image.png")
    }

    static func saveImage(_ image: UIImage) -> Bool {
        guard let url = sharedImageURL else { return false }
        try? FileManager.default.removeItem(at: url)
        let resized = resizeImage(image, maxDim: 2048)
        guard let data = resized.pngData() else { return false }
        do {
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            return false
        }
    }

    static func loadImage() -> UIImage? {
        guard let url = sharedImageURL,
              FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func deleteImage() {
        guard let url = sharedImageURL else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private static func resizeImage(_ image: UIImage, maxDim: CGFloat) -> UIImage {
        let size = image.size
        let scale = min(maxDim / max(size.width, size.height), 1.0)
        guard scale < 1.0 else { return image }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
