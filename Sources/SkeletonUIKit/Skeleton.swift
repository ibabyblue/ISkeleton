#if canImport(UIKit)
import UIKit
import SkeletonCore
import ObjectiveC

/// 全局骨架外观入口。
public enum Skeleton {
    /// 全局默认外观；App 启动时可设置一次，所有 `skeleton(_:)` 默认使用。
    public static var appearance: SkeletonConfiguration = .default
}

private enum AssociatedKeys {
    static var overlay: UInt8 = 0
}

public extension UIView {
    /// active 时在自身 bounds 上叠加扫光占位（不参与 intrinsic size）；false 时移除并恢复真实内容。
    /// 尺寸完全由 host 自身内容/文案撑起；UILabel 会按文案逐行画占位条。
    /// cornerRadius 为 nil 时取 `Skeleton.appearance.cornerRadius`。
    func skeleton(_ active: Bool, cornerRadius: CGFloat? = nil) {
        if active {
            if currentSkeletonOverlay != nil { return }   // 幂等
            let config = Skeleton.appearance
            let overlay = SkeletonOverlayView(
                host: self, configuration: config,
                cornerRadius: cornerRadius ?? config.cornerRadius)
            addSubview(overlay)
            overlay.setNeedsLayout()
            overlay.layoutIfNeeded()
            ShimmerClock.shared.register(overlay)
            currentSkeletonOverlay = overlay
        } else {
            guard let overlay = currentSkeletonOverlay else { return }
            ShimmerClock.shared.unregister(overlay)
            overlay.removeFromSuperview()
            currentSkeletonOverlay = nil
        }
    }

    private var currentSkeletonOverlay: SkeletonOverlayView? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.overlay) as? SkeletonOverlayView }
        set { objc_setAssociatedObject(self, &AssociatedKeys.overlay, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}
#endif
