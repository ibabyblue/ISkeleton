import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Resolves dynamic line heights for SwiftUI text styles through native font APIs.
///
/// SwiftUI fonts do not expose line metrics directly, so each supported platform
/// maps the style to its UIKit or AppKit equivalent.
enum TextStyleMetrics {
    /// Returns the current dynamic line height for a SwiftUI text style.
    ///
    /// - Parameter style: The semantic SwiftUI text style to resolve.
    /// - Returns: The native preferred font's line height, or `17` on unsupported platforms.
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
    /// Maps a SwiftUI text style to the equivalent UIKit semantic style.
    ///
    /// - Parameter s: The SwiftUI text style to map.
    /// - Returns: The corresponding UIKit style, or `.body` for an unknown future style.
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
    /// Maps a SwiftUI text style to the equivalent AppKit semantic style.
    ///
    /// - Parameter s: The SwiftUI text style to map.
    /// - Returns: The corresponding AppKit style, or `.body` for an unknown future style.
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
