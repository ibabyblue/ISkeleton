#if canImport(UIKit)
import UIKit
import SkeletonCore
import ObjectiveC

/// 全局骨架外观入口。仅主线程读写（App 启动时一次性设置）。
@MainActor
public enum Skeleton {
    /// 全局默认外观；所有 `skeleton(_:)` 默认使用（未传 per-call appearance 时）。
    public static var appearance: SkeletonConfiguration = .default
}

/// 关联对象 key：独立分配的稳定指针。
nonisolated(unsafe) private let skeletonOverlayKey = malloc(1)!
nonisolated(unsafe) private let skeletonTextColorKey = malloc(1)!

public extension UIView {
    /// active 时叠加骨架并隐藏 host 内容（UILabel 文字）；false 移除并还原。
    /// 非 UILabel：单条用 `shape`（如 `.circle` 圆形头像）；UILabel：文案驱动逐行（shape 被忽略）。
    ///
    /// 契约：loading 前先给 host 设置代表性内容（UILabel 设代表性文案）撑出尺寸/行数，再 `skeleton(true)`；
    /// 骨架激活期间改文案，请先 `skeleton(false)` 再设文案后重新 `skeleton(true)`。
    /// 注：仅隐藏 UILabel 的 `textColor`；`attributedText` 中显式着色的富文本不在此机制内。
    /// `appearance` 非空时仅本次激活使用，否则用全局 `Skeleton.appearance`。
    @MainActor
    func skeleton(_ active: Bool,
                  shape: SkeletonShape = .roundedRect(cornerRadius: nil),
                  appearance: SkeletonConfiguration? = nil) {
        if active {
            if let existing = currentSkeletonOverlay, existing.superview === self {
                return   // 幂等
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
            // 先无条件还原文字（自守卫于 savedTextColor），使恢复不依赖 overlay 状态。
            restoreLabelTextIfNeeded()
            guard let overlay = currentSkeletonOverlay else { return }
            ShimmerClock.shared.unregister(overlay)
            overlay.removeFromSuperview()
            currentSkeletonOverlay = nil
        }
    }

    /// 暂存并清空 UILabel 文字颜色（骨架期不可见真实文字）。
    private func hideLabelTextIfNeeded() {
        guard let label = self as? UILabel, savedTextColor == nil else { return }
        savedTextColor = label.textColor
        label.textColor = .clear
    }

    private func restoreLabelTextIfNeeded() {
        guard let label = self as? UILabel, let color = savedTextColor else { return }
        label.textColor = color
        savedTextColor = nil
    }

    private var currentSkeletonOverlay: SkeletonOverlayView? {
        get { objc_getAssociatedObject(self, skeletonOverlayKey) as? SkeletonOverlayView }
        set { objc_setAssociatedObject(self, skeletonOverlayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private var savedTextColor: UIColor? {
        get { objc_getAssociatedObject(self, skeletonTextColorKey) as? UIColor }
        set { objc_setAssociatedObject(self, skeletonTextColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
#endif
