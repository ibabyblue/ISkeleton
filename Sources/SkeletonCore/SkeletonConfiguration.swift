import Foundation
import CoreGraphics

/// The platform-neutral appearance and animation parameters for a skeleton.
public struct SkeletonConfiguration: Equatable, Sendable {
    /// The base fill color of each placeholder.
    public var baseColor: SkeletonRGBA
    /// The color at the center of the moving highlight band.
    public var highlightColor: SkeletonRGBA
    /// The duration of one complete sweep, in seconds.
    public var duration: TimeInterval
    /// The highlight band's width normalized to the placeholder's sweep axis.
    public var bandWidth: CGFloat
    /// The default corner radius for rounded-rectangle placeholders, in points.
    public var cornerRadius: CGFloat
    /// The direction in which the highlight band moves.
    public var direction: ShimmerDirection

    /// Creates a skeleton configuration.
    ///
    /// - Parameters:
    ///   - baseColor: The placeholder's base fill color.
    ///   - highlightColor: The color at the center of the highlight band.
    ///   - duration: The duration of one sweep, in seconds. The default is `1.4`.
    ///   - bandWidth: The normalized highlight-band width. The default is `0.6`.
    ///   - cornerRadius: The default rounded-rectangle radius, in points. The default is `5`.
    ///   - direction: The shimmer sweep direction. The default is ``ShimmerDirection/leftToRight``.
    public init(baseColor: SkeletonRGBA,
                highlightColor: SkeletonRGBA,
                duration: TimeInterval = 1.4,
                bandWidth: CGFloat = 0.6,
                cornerRadius: CGFloat = 5,
                direction: ShimmerDirection = .leftToRight) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.duration = duration
        self.bandWidth = bandWidth
        self.cornerRadius = cornerRadius
        self.direction = direction
    }

    /// The default neutral-gray fill and near-white highlight appearance.
    public static let `default` = SkeletonConfiguration(
        baseColor: SkeletonRGBA(r: 0.91, g: 0.85, b: 0.85, a: 0.8),
        highlightColor: SkeletonRGBA(r: 0.99, g: 0.98, b: 0.98, a: 0.8)
    )
}
