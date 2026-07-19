#if canImport(UIKit)
import UIKit
import SkeletonCore

/// Adds UIKit color conversion to platform-neutral skeleton colors.
extension SkeletonRGBA {
    /// The equivalent sRGB UIKit color.
    var uiColor: UIColor {
        UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
#endif
