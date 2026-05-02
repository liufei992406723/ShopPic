import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var vm: AppViewModel

    var body: some View {
        List {
            if vm.searchHistory.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "clock.badge.questionmark",
                    description: Text("Your recent searches will appear here")
                )
            } else {
                ForEach(vm.searchHistory) { entry in
                    Button {
                        reuseHistory(entry)
                    } label: {
                        HStack(spacing: 12) {
                            thumbnail(for: entry)
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 6))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(entry.platform.displayName)
                                    .foregroundStyle(.primary)
                                Text(entry.date, style: .relative)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "arrow.up.forward.app")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("History")
    }

    @ViewBuilder
    private func thumbnail(for entry: HistoryEntry) -> some View {
        if let thumb = entry.thumbnail {
            Image(uiImage: thumb)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: entry.platform.systemImageName)
                .font(.title3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.quaternary)
        }
    }

    private func reuseHistory(_ entry: HistoryEntry) {
        UIPasteboard.general.image = vm.sharedImage
        vm.recordPlatformUse(entry.platform)
        PlatformService.jumpOrAlert(to: entry.platform)
    }
}
