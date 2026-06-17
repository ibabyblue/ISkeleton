import CoreGraphics

/// 扫光方向。每个 case 给出归一化起止点（x,y ∈ 0...1）。
public enum ShimmerDirection: Sendable, Equatable, CaseIterable {
    case leftToRight, rightToLeft, topToBottom, bottomToTop
    case topLeftToBottomRight, topRightToBottomLeft
    case bottomLeftToTopRight, bottomRightToTopLeft

    public var start: CGPoint {
        switch self {
        case .leftToRight:          return CGPoint(x: 0,   y: 0.5)
        case .rightToLeft:          return CGPoint(x: 1,   y: 0.5)
        case .topToBottom:          return CGPoint(x: 0.5, y: 0)
        case .bottomToTop:          return CGPoint(x: 0.5, y: 1)
        case .topLeftToBottomRight: return CGPoint(x: 0,   y: 0)
        case .topRightToBottomLeft: return CGPoint(x: 1,   y: 0)
        case .bottomLeftToTopRight: return CGPoint(x: 0,   y: 1)
        case .bottomRightToTopLeft: return CGPoint(x: 1,   y: 1)
        }
    }

    public var end: CGPoint {
        switch self {
        case .leftToRight:          return CGPoint(x: 1,   y: 0.5)
        case .rightToLeft:          return CGPoint(x: 0,   y: 0.5)
        case .topToBottom:          return CGPoint(x: 0.5, y: 1)
        case .bottomToTop:          return CGPoint(x: 0.5, y: 0)
        case .topLeftToBottomRight: return CGPoint(x: 1,   y: 1)
        case .topRightToBottomLeft: return CGPoint(x: 0,   y: 1)
        case .bottomLeftToTopRight: return CGPoint(x: 1,   y: 0)
        case .bottomRightToTopLeft: return CGPoint(x: 0,   y: 0)
        }
    }

    /// 给定相位与带宽，返回该帧梯度的动画起止点（沿 start→end 轴平移的高光带）。
    /// leftToRight 退化为 ((phase, 0.5), (phase+bandWidth, 0.5))，与既有实现一致。
    public func gradientPoints(phase: CGFloat, bandWidth: CGFloat) -> (start: CGPoint, end: CGPoint) {
        let s = start, e = end
        func lerp(_ t: CGFloat) -> CGPoint {
            CGPoint(x: s.x + (e.x - s.x) * t, y: s.y + (e.y - s.y) * t)
        }
        return (lerp(phase), lerp(phase + bandWidth))
    }
}
