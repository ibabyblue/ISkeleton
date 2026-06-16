import SwiftUI
import SkeletonSwiftUI

/// SwiftUI 演示：每个 slot 用 `.skeleton(isLoading)`；loading 时喂代表性内容撑尺寸。
/// 多行 bio 在 SwiftUI 下是「整块覆盖」。
struct SwiftUIDemoView: View {
    @State private var isLoading = true
    @State private var profiles: [DemoProfile] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(displayCards) { card in
                        cardView(card)
                    }
                }
                .padding()
            }
            .navigationTitle("SwiftUI")
            .toolbar {
                Button("Reload") { reload() }
            }
        }
        .skeletonAppearance(.default)
        .onAppear { if profiles.isEmpty { reload() } }
    }

    private var displayCards: [DemoProfile] {
        isLoading ? DemoProfile.placeholderCards : profiles
    }

    @ViewBuilder
    private func cardView(_ p: DemoProfile) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 56, height: 56)
                .skeleton(isLoading)
            VStack(alignment: .leading, spacing: 8) {
                Text(p.name).font(.headline)
                    .skeleton(isLoading)
                Text(p.price).font(.subheadline).foregroundStyle(.pink)
                    .skeleton(isLoading)
                Text(p.bio).font(.footnote).foregroundStyle(.secondary)
                    .skeleton(isLoading)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    private func reload() {
        isLoading = true
        profiles = []
        Task {
            let loaded = await DemoLoader.load()
            profiles = loaded
            isLoading = false
        }
    }
}
