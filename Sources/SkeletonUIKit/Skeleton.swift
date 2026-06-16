#if canImport(UIKit)
import UIKit
import SkeletonCore
import ObjectiveC

/// 全局骨架外观入口。建议在主线程（App 启动时）一次性设置。
public enum Skeleton {
    /// 全局默认外观；所有 `skeleton(_:)` 默认使用。
    nonisolated(unsafe) public static var appearance: SkeletonConfiguration = .default
}

/// 关联对象 key：独立分配的稳定指针，避免对可变全局取址（严格并发友好）。
nonisolated(unsafe) private let skeletonOverlayKey = malloc(1)!

public extension UIView {
    /// active 时在自身 bounds 上叠加扫光占位（不参与 intrinsic size）；false 时移除并恢复真实内容。
    /// 尺寸完全由 host 自身内容/文案撑起；UILabel 会按文案逐行画占位条。
    /// cornerRadius 为 nil 时取 `Skeleton.appearance.cornerRadius`。
    ///
    /// 契约：loading 前先给 host 设置代表性内容（UILabel 设代表性文案）来撑出尺寸/行数，再调 `skeleton(true)`；
    /// 占位条在 overlay 创建时及尺寸变化时构建。若在骨架激活期间修改 host 文案，请先 `skeleton(false)` 再设文案后重新 `skeleton(true)`。
    func skeleton(_ active: Bool, cornerRadius: CGFloat? = nil) {
        if active {
            if let existing = currentSkeletonOverlay, existing.superview === self {
                return   // 已激活且仍在视图层级：幂等
            }
            // 旧 overlay 可能已被视图复用等外部路径移除：先清理再重建，避免野指针/重复。
            if let stale = currentSkeletonOverlay {
                ShimmerClock.shared.unregister(stale)
                stale.removeFromSuperview()
            }
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
        get { objc_getAssociatedObject(self, skeletonOverlayKey) as? SkeletonOverlayView }
        set { objc_setAssociatedObject(self, skeletonOverlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
#endif
