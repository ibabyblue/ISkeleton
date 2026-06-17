import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// 把 SwiftUI 的 `Font.TextStyle` 换算成单行高度（跟随系统动态字号）。
/// SwiftUI 的 `Font` 不透明、无法直接取行高，故经平台原生字体 API 取值。
enum TextStyleMetrics {
    static func lineHeight(for style: Font.TextStyle) -> CGFloat {
        #if canImport(UIKit)
        return UIFont.preferredFont(forTextStyle: uiTextStyle(style)).lineHeight
        #elseif canImport(AppKit)
        return NSFont.preferredFont(forTextStyle: nsTextStyle(style)).boundingRectForFont.height
        #else
        return 17
        #endif
    }

    #if canImport(UIKit)
    private static func uiTextStyle(_ s: Font.TextStyle) -> UIFont.TextStyle {
        switch s {
        case .largeTitle:  return .largeTitle
        case .title:       return .title1
        case .title2:      return .title2
        case .title3:      return .title3
        case .headline:    return .headline
        case .subheadline: return .subheadline
        case .body:        return .body
        case .callout:     return .callout
        case .footnote:    return .footnote
        case .caption:     return .caption1
        case .caption2:    return .caption2
        @unknown default:  return .body
        }
    }
    #elseif canImport(AppKit)
    private static func nsTextStyle(_ s: Font.TextStyle) -> NSFont.TextStyle {
        switch s {
        case .largeTitle:  return .largeTitle
        case .title:       return .title1
        case .title2:      return .title2
        case .title3:      return .title3
        case .headline:    return .headline
        case .subheadline: return .subheadline
        case .body:        return .body
        case .callout:     return .callout
        case .footnote:    return .footnote
        case .caption:     return .caption1
        case .caption2:    return .caption2
        @unknown default:  return .body
        }
    }
    #endif
}
