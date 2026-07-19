import SwiftUI
import SkeletonCore

/// Stores the inherited skeleton configuration for a SwiftUI environment.
private struct SkeletonAppearanceKey: EnvironmentKey {
    /// The configuration used when no ancestor supplies an override.
    static let defaultValue: SkeletonConfiguration = .default
}

/// Adds skeleton appearance storage to SwiftUI environment values.
public extension EnvironmentValues {
    /// The configuration inherited by skeleton modifiers in the current subtree.
    var skeletonAppearance: SkeletonConfiguration {
        get { self[SkeletonAppearanceKey.self] }
        set { self[SkeletonAppearanceKey.self] = newValue }
    }
}

/// Adds subtree-scoped skeleton appearance configuration to SwiftUI views.
public extension View {
    /// Injects a skeleton appearance into this view's descendant environment.
    ///
    /// Nested calls override the configuration only for their own subtrees. Without
    /// an override, skeleton modifiers use ``SkeletonConfiguration/default``.
    ///
    /// - Parameter config: The configuration to supply to descendant skeletons.
    /// - Returns: A view whose descendants inherit the supplied appearance.
    func skeletonAppearance(_ config: SkeletonConfiguration) -> some View {
        environment(\.skeletonAppearance, config)
    }
}
