#if canImport(UIKit)
import UIKit
import SkeletonCore
import ObjectiveC

/// Provides the main-actor global appearance used by UIKit skeleton activations.
@MainActor
public enum Skeleton {
    /// The configuration snapshotted by activations that do not supply a per-call override.
    public static var appearance: SkeletonConfiguration = .default
}

/// The stable associated-object key for a view's active overlay.
nonisolated(unsafe) private let skeletonOverlayKey = malloc(1)!
/// The stable associated-object key for a label's saved text color.
nonisolated(unsafe) private let skeletonTextColorKey = malloc(1)!

/// Adds main-actor geometric and image-masked skeleton activation to UIKit views.
public extension UIView {
    /// Activates or removes a geometric skeleton overlay on this view.
    ///
    /// Set representative label text before activation because overlay geometry is
    /// captured when the skeleton is created. To refresh an active skeleton after
    /// content changes, deactivate it, update content, and activate it again.
    /// Repeating the same active state is idempotent. Multiline labels use their
    /// text layout instead of `shape`, and only `textColor` is hidden and restored.
    ///
    /// - Parameters:
    ///   - active: `true` to create the overlay or `false` to remove it and restore hidden label color.
    ///   - shape: The geometric shape used for non-label hosts. Multiline labels use line geometry instead.
    ///   - appearance: A per-activation configuration. Pass `nil` to snapshot ``Skeleton/appearance``.
    @MainActor
    func skeleton(_ active: Bool,
                  shape: SkeletonShape = .roundedRect(cornerRadius: nil),
                  appearance: SkeletonConfiguration? = nil) {
        if active {
            if let existing = currentSkeletonOverlay, existing.superview === self {
                return   // Repeated activation is idempotent.
            }
            if let stale = currentSkeletonOverlay {
                ShimmerClock.shared.unregister(stale)
                stale.removeFromSuperview()
            }
            hideLabelTextIfNeeded()
            let config = appearance ?? Skeleton.appearance
            let overlay = SkeletonOverlayView(host: self, configuration: config, shape: shape)
            addSubview(overlay)
            overlay.setNeedsLayout()
            overlay.layoutIfNeeded()
            ShimmerClock.shared.register(overlay)
            currentSkeletonOverlay = overlay
        } else {
            tearDownSkeleton()
        }
    }

    /// Activates or removes a skeleton clipped by a bitmap image's alpha channel.
    ///
    /// ``SkeletonMask/ownImage`` resolves only for a `UIImageView`. A missing image
    /// or an image without a `CGImage` leaves the view unchanged. Image and geometric
    /// skeletons share one overlay, so deactivate before switching rendering modes.
    /// Repeating activation while an overlay is present keeps the existing overlay.
    ///
    /// - Parameters:
    ///   - active: `true` to create an image-masked overlay or `false` to remove it.
    ///   - mask: The bitmap image source whose alpha clips the shimmer.
    ///   - appearance: A per-activation configuration. Pass `nil` to snapshot ``Skeleton/appearance``.
    @MainActor
    func skeleton(_ active: Bool, mask: SkeletonMask,
                  appearance: SkeletonConfiguration? = nil) {
        if active {
            guard let cg = resolveMaskCGImage(mask) else { return }
            if let existing = currentSkeletonOverlay, existing.superview === self { return }
            if let stale = currentSkeletonOverlay {
                ShimmerClock.shared.unregister(stale)
                stale.removeFromSuperview()
            }
            let config = appearance ?? Skeleton.appearance
            let overlay = SkeletonOverlayView(host: self, configuration: config,
                                              shape: .roundedRect(cornerRadius: nil), maskImage: cg)
            addSubview(overlay)
            overlay.setNeedsLayout()
            overlay.layoutIfNeeded()
            ShimmerClock.shared.register(overlay)
            currentSkeletonOverlay = overlay
        } else {
            tearDownSkeleton()
        }
    }

    /// Resolves a mask source to the bitmap required by Core Animation.
    ///
    /// - Parameter mask: An explicit image or the receiver's own image.
    /// - Returns: A bitmap image, or `nil` when the source is unavailable or not bitmap-backed.
    private func resolveMaskCGImage(_ mask: SkeletonMask) -> CGImage? {
        switch mask {
        case .image(let img): return img.cgImage
        case .ownImage:       return (self as? UIImageView)?.image?.cgImage
        }
    }

    /// Removes the current overlay, unregisters it from the clock, and restores label color.
    private func tearDownSkeleton() {
        // Restore text first so cleanup does not depend on matching overlay storage.
        restoreLabelTextIfNeeded()
        guard let overlay = currentSkeletonOverlay else { return }
        ShimmerClock.shared.unregister(overlay)
        overlay.removeFromSuperview()
        currentSkeletonOverlay = nil
    }

    /// Saves and clears a label's text color once so real text stays hidden under shimmer.
    private func hideLabelTextIfNeeded() {
        guard let label = self as? UILabel, savedTextColor == nil else { return }
        savedTextColor = label.textColor
        label.textColor = .clear
    }

    /// Restores a previously saved label text color and clears the saved value.
    private func restoreLabelTextIfNeeded() {
        guard let label = self as? UILabel, let color = savedTextColor else { return }
        label.textColor = color
        savedTextColor = nil
    }

    /// The overlay retained on this view through Objective-C associated storage.
    private var currentSkeletonOverlay: SkeletonOverlayView? {
        get { objc_getAssociatedObject(self, skeletonOverlayKey) as? SkeletonOverlayView }
        set { objc_setAssociatedObject(self, skeletonOverlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    /// The original label color retained while a skeleton hides the label text.
    private var savedTextColor: UIColor? {
        get { objc_getAssociatedObject(self, skeletonTextColorKey) as? UIColor }
        set { objc_setAssociatedObject(self, skeletonTextColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
#endif
