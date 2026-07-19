#if canImport(UIKit)
import UIKit

/// A UIKit image source whose alpha channel defines a skeleton silhouette.
public enum SkeletonMask {
    /// Uses the supplied image when it provides a bitmap-backed `CGImage`.
    case image(UIImage)
    /// Uses the receiver's image when the skeleton host is a `UIImageView`.
    case ownImage
}
#endif
