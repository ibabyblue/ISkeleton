import CoreGraphics

/// A geometric shape used to clip a skeleton placeholder.
public enum SkeletonShape: Equatable, Sendable {
    /// A rounded rectangle with an optional explicit radius.
    ///
    /// A `nil` radius uses the active configuration's default corner radius.
    case roundedRect(cornerRadius: CGFloat?)
    /// A circular placeholder whose radius is half the shorter dimension.
    case circle
    /// A capsule placeholder whose radius is half the shorter dimension.
    case capsule

    /// Resolves the effective corner radius for a concrete placeholder size.
    ///
    /// - Parameters:
    ///   - size: The placeholder's width and height, in points.
    ///   - defaultRadius: The fallback radius for a rounded rectangle with no explicit value.
    /// - Returns: The explicit or fallback rounded-rectangle radius, or half the shorter dimension for circles and capsules.
    public func cornerRadius(for size: CGSize, default defaultRadius: CGFloat) -> CGFloat {
        switch self {
        case .roundedRect(let cr): return cr ?? defaultRadius
        case .circle, .capsule:    return min(size.width, size.height) / 2
        }
    }
}
