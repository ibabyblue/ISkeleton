import CoreGraphics

/// 占位形状。circle/capsule 由 size 推出圆角；roundedRect 用指定或默认圆角。
public enum SkeletonShape: Equatable, Sendable {
    case roundedRect(cornerRadius: CGFloat?)   // nil → 用 config.cornerRadius
    case circle
    case capsule

    /// 实际圆角：circle/capsule = min(w,h)/2；roundedRect(nil) = default；roundedRect(cr) = cr。
    public func cornerRadius(for size: CGSize, default defaultRadius: CGFloat) -> CGFloat {
        switch self {
        case .roundedRect(let cr): return cr ?? defaultRadius
        case .circle, .capsule:    return min(size.width, size.height) / 2
        }
    }
}
