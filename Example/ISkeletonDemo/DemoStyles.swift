import SkeletonCore

/// Visually distinct color presets used to exercise appearance changes.
enum DemoColorTheme: String, CaseIterable, Identifiable {
    /// The package default, a dark neutral palette, and a tinted palette.
    case `default`, dark, tinted
    /// The raw-value identity consumed by SwiftUI pickers.
    var id: String { rawValue }

    /// The localized title displayed by the Example control panel.
    var title: String {
        switch self {
        case .default: return "默认"
        case .dark:    return "深色"
        case .tinted:  return "调色"
        }
    }

    /// The base skeleton color for this preset.
    var base: SkeletonRGBA {
        switch self {
        case .default: return SkeletonRGBA(r: 0.91, g: 0.85, b: 0.85, a: 0.8)
        case .dark:    return SkeletonRGBA(r: 0.24, g: 0.24, b: 0.27, a: 0.9)
        case .tinted:  return SkeletonRGBA(r: 0.62, g: 0.66, b: 0.92, a: 0.8)
        }
    }

    /// The highlight-band color for this preset.
    var highlight: SkeletonRGBA {
        switch self {
        case .default: return SkeletonRGBA(r: 0.99, g: 0.98, b: 0.98, a: 0.8)
        case .dark:    return SkeletonRGBA(r: 0.46, g: 0.46, b: 0.52, a: 0.95)
        case .tinted:  return SkeletonRGBA(r: 0.85, g: 0.88, b: 0.99, a: 0.95)
        }
    }
}

/// Returns the localized control-panel title for every shimmer direction.
///
/// - Parameter d: The direction whose title is required.
/// - Returns: A title containing the direction's visual arrow.
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

/// A picker-friendly Example shape that maps to the package's associated-value shape.
enum DemoShape: String, CaseIterable, Identifiable {
    /// The circle, capsule, and rounded-rectangle choices shown in both labs.
    case circle, capsule, roundedRect
    /// The raw-value identity consumed by SwiftUI pickers.
    var id: String { rawValue }

    /// The localized title displayed by the Example control panel.
    var title: String {
        switch self {
        case .circle:      return "圆形"
        case .capsule:     return "胶囊"
        case .roundedRect: return "圆角矩形"
        }
    }

    /// The package shape represented by this picker value.
    ///
    /// Rounded rectangles use a `nil` radius so the active configuration supplies it.
    var skeletonShape: SkeletonShape {
        switch self {
        case .circle:      return .circle
        case .capsule:     return .capsule
        case .roundedRect: return .roundedRect(cornerRadius: nil)
        }
    }
}
