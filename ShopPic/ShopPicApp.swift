import SwiftUI

@main
struct ShopPicApp: App {
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .onOpenURL { _ in
                    viewModel.loadSharedImage()
                }
                .onReceive(
                    NotificationCenter.default.publisher(
                        for: UIScene.willEnterForegroundNotification
                    )
                ) { _ in
                    viewModel.loadSharedImage()
                }
        }
    }
}
