#if canImport(UIKit)
import UIKit

/// 图片蒙版来源：骨架轮廓取自图片 alpha。
public enum SkeletonMask {
    /// 指定蒙版图。
    case image(UIImage)
    /// 用 `UIImageView` 自身的 `image`（仅对 UIImageView 有效）。
    case ownImage
}
#endif
