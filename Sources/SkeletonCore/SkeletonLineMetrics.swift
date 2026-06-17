import CoreGraphics

/// 多行文本骨架的纯几何换算：由 footprint 高度与单行高度推出行数与单条高度。
/// 与平台/字体无关 —— 单行高度由调用方（SwiftUI/UIKit 层）提供。
public enum SkeletonLineMetrics {
    /// footprint 高度按单行高度反推行数（四舍五入，至少 1 行）。
    public static func lineCount(height: CGFloat, lineHeight: CGFloat) -> Int {
        guard lineHeight > 0, height > 0 else { return 1 }
        return max(1, Int((height / lineHeight).rounded()))
    }

    /// 单条骨架高度 ≈ 字形主体（行高的 ratio 倍）；上下留白即行距。
    public static func barHeight(lineHeight: CGFloat, ratio: CGFloat = 0.7) -> CGFloat {
        max(0, lineHeight * ratio)
    }
}
