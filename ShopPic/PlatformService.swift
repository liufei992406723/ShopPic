import UIKit

enum Platform: String, CaseIterable, Identifiable, Codable {
    case taobao
    case jd
    case pinduoduo
    case douyin

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .taobao:   return "Taobao"
        case .jd:       return "JD"
        case .pinduoduo: return "Pinduoduo"
        case .douyin:   return "Douyin"
        }
    }

    var systemImageName: String {
        switch self {
        case .taobao:   return "bag.fill"
        case .jd:       return "cart.fill"
        case .pinduoduo: return "basket.fill"
        case .douyin:   return "play.rectangle.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .taobao:   return "#FF5000"
        case .jd:       return "#C91623"
        case .pinduoduo: return "#E02E24"
        case .douyin:   return "#010101"
        }
    }

    var urlScheme: String {
        switch self {
        case .taobao:   return "taobao://"
        case .jd:       return "openapp.jd.com://"
        case .pinduoduo: return "pinduoduo://"
        case .douyin:   return "snssdk1128://"
        }
    }

    var webFallbackURL: URL? {
        switch self {
        case .taobao:   return URL(string: "https://www.taobao.com")
        case .jd:       return URL(string: "https://www.jd.com")
        case .pinduoduo: return URL(string: "https://mobile.yangkeduo.com")
        case .douyin:   return URL(string: "https://www.douyin.com")
        }
    }

    var isInstalled: Bool {
        guard let url = URL(string: urlScheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    func open() {
        guard let url = URL(string: urlScheme) else { return }
        UIApplication.shared.open(url)
    }
}

enum PlatformService {
    static func jumpOrAlert(to platform: Platform) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else { return }

        if platform.isInstalled {
            platform.open()
        } else {
            let alert = UIAlertController(
                title: "\(platform.displayName) Not Installed",
                message: "Open in Safari instead?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            if let webURL = platform.webFallbackURL {
                alert.addAction(UIAlertAction(title: "Open Website", style: .default) { _ in
                    UIApplication.shared.open(webURL)
                })
            }
            rootVC.present(alert, animated: true)
        }
    }
}
