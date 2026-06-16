#if canImport(UIKit)
import UIKit
import SkeletonCore

extension SkeletonRGBA {
    /// 转 UIColor。
    var uiColor: UIColor {
        UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
#endif
