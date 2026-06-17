import Foundation
import CoreGraphics

/// 骨架外观与扫光参数。所有字段有合理默认值。
public struct SkeletonConfiguration: Equatable, Sendable {
    /// 占位条底色。
    public var baseColor: SkeletonRGBA
    /// 扫光高光色。
    public var highlightColor: SkeletonRGBA
    /// 单次扫光时长（秒）。
    public var duration: TimeInterval
    /// 高光带归一化宽度。
    public var bandWidth: CGFloat
    /// 占位条默认圆角。
    public var cornerRadius: CGFloat
    /// 扫光方向。
    public var direction: ShimmerDirection

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

    /// 默认外观：中性灰底 + 偏白高光。
    public static let `default` = SkeletonConfiguration(
        baseColor: SkeletonRGBA(r: 0.91, g: 0.85, b: 0.85, a: 0.8),
        highlightColor: SkeletonRGBA(r: 0.99, g: 0.98, b: 0.98, a: 0.8)
    )
}
