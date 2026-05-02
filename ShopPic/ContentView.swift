import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    imagePreviewSection
                    platformGridSection
                    quickJumpSection
                }
                .padding()
            }
            .navigationTitle("ShopPic")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
        }
    }

    // MARK: - Image Preview

    @ViewBuilder
    private var imagePreviewSection: some View {
        if let image = vm.sharedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 4)
                .overlay(alignment: .topTrailing) {
                    Button {
                        vm.clearImage()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, .regularMaterial)
                            .padding(8)
                    }
                }
        } else {
            emptyStateView
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Share an image from another app\nto start searching")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 280)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Platform Grid

    private var platformGridSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(Platform.allCases) { platform in
                PlatformButton(platform: platform) {
                    handlePlatformTap(platform)
                }
            }
        }
    }

    private func handlePlatformTap(_ platform: Platform) {
        if let image = vm.sharedImage {
            UIPasteboard.general.image = image
        }
        vm.recordPlatformUse(platform)
        vm.addHistory(platform: platform, image: vm.sharedImage)
        PlatformService.jumpOrAlert(to: platform)
    }

    // MARK: - Quick Jump

    @ViewBuilder
    private var quickJumpSection: some View {
        if !vm.recentPlatforms.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 4)

                HStack(spacing: 12) {
                    ForEach(Array(vm.recentPlatforms.prefix(3).enumerated()), id: \.element.rawValue) { _, platform in
                        Button {
                            handlePlatformTap(platform)
                        } label: {
                            Label(platform.displayName, systemImage: platform.systemImageName)
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
