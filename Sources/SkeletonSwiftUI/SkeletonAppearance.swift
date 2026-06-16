import SwiftUI
import SkeletonCore

private struct SkeletonAppearanceKey: EnvironmentKey {
    static let defaultValue: SkeletonConfiguration = .default
}

public extension EnvironmentValues {
    var skeletonAppearance: SkeletonConfiguration {
        get { self[SkeletonAppearanceKey.self] }
        set { self[SkeletonAppearanceKey.self] = newValue }
    }
}

public extension View {
    /// 注入骨架外观；子树内所有 `.skeleton` 复用之。未注入时用 `SkeletonConfiguration.default`。
    func skeletonAppearance(_ config: SkeletonConfiguration) -> some View {
        environment(\.skeletonAppearance, config)
    }
}
