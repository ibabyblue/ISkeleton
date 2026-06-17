import SkeletonCore

/// demo 颜色主题预设；演示「换一套 baseColor/highlightColor 外观」。三者肉眼可区分。
enum DemoColorTheme: String, CaseIterable, Identifiable {
    case `default`, dark, tinted
    var id: String { rawValue }

    var title: String {
        switch self {
        case .default: return "默认"
        case .dark:    return "深色"
        case .tinted:  return "调色"
        }
    }

    /// 占位条底色。
    var base: SkeletonRGBA {
        switch self {
        case .default: return SkeletonRGBA(r: 0.91, g: 0.85, b: 0.85, a: 0.8)
        case .dark:    return SkeletonRGBA(r: 0.24, g: 0.24, b: 0.27, a: 0.9)
        case .tinted:  return SkeletonRGBA(r: 0.62, g: 0.66, b: 0.92, a: 0.8)
        }
    }

    /// 扫光高光色。
    var highlight: SkeletonRGBA {
        switch self {
        case .default: return SkeletonRGBA(r: 0.99, g: 0.98, b: 0.98, a: 0.8)
        case .dark:    return SkeletonRGBA(r: 0.46, g: 0.46, b: 0.52, a: 0.95)
        case .tinted:  return SkeletonRGBA(r: 0.85, g: 0.88, b: 0.99, a: 0.95)
        }
    }
}

/// 扫光方向的展示名（覆盖 ShimmerDirection.allCases 全部 8 项）。
func demoDirectionTitle(_ d: ShimmerDirection) -> String {
    switch d {
    case .leftToRight:          return "左 → 右"
    case .rightToLeft:          return "右 → 左"
    case .topToBottom:          return "上 → 下"
    case .bottomToTop:          return "下 → 上"
    case .topLeftToBottomRight: return "左上 → 右下"
    case .topRightToBottomLeft: return "右上 → 左下"
    case .bottomLeftToTopRight: return "左下 → 右上"
    case .bottomRightToTopLeft: return "右下 → 左上"
    }
}

/// demo 本地形状枚举：SkeletonShape 带关联值不便做 Picker/分段，这里用可枚举的简单 case 映射过去。
enum DemoShape: String, CaseIterable, Identifiable {
    case circle, capsule, roundedRect
    var id: String { rawValue }

    var title: String {
        switch self {
        case .circle:      return "圆形"
        case .capsule:     return "胶囊"
        case .roundedRect: return "圆角矩形"
        }
    }

    /// roundedRect 传 nil → 用 config.cornerRadius。
    var skeletonShape: SkeletonShape {
        switch self {
        case .circle:      return .circle
        case .capsule:     return .capsule
        case .roundedRect: return .roundedRect(cornerRadius: nil)
        }
    }
}
