#if canImport(UIKit)
import UIKit
import SkeletonCore

/// 覆盖在 host 上的扫光占位层。不参与 host 的 intrinsic size；尺寸跟随 host bounds。
final class SkeletonOverlayView: UIView, ShimmerDriven {

    let configuration: SkeletonConfiguration
    private let cornerRadius: CGFloat
    /// 弱引用 host，用于读取 UILabel 的文案排版信息。
    private weak var host: UIView?

    /// 所有占位条所在的容器层。
    private let barsLayer = CALayer()
    /// 扫光高光渐变层；以占位条形状作 mask，只在条形区域透出高光。
    private let shimmerLayer = CAGradientLayer()
    private var lastBuiltSize: CGSize = .zero

    init(host: UIView, configuration: SkeletonConfiguration, cornerRadius: CGFloat) {
        self.host = host
        self.configuration = configuration
        self.cornerRadius = cornerRadius
        super.init(frame: host.bounds)
        isUserInteractionEnabled = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        layer.addSublayer(barsLayer)

        shimmerLayer.colors = [UIColor.clear.cgColor,
                               configuration.highlightColor.uiColor.cgColor,
                               UIColor.clear.cgColor]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(shimmerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var shimmerConfiguration: SkeletonConfiguration { configuration }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastBuiltSize, !bounds.isEmpty else { return }
        lastBuiltSize = bounds.size
        rebuildBars()
    }

    /// 按 host 形态重建占位条：barsLayer 画底色条；shimmerLayer 覆盖 bounds 并以同形状的 mask
    /// 只在条形区域透出高光。高光的移动靠 applyShimmerPhase 改 start/endPoint（不动 frame）。
    private func rebuildBars() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        barsLayer.frame = bounds
        barsLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let base = configuration.baseColor.uiColor.cgColor
        let rects = barRects()
        let maskContainer = CALayer()
        maskContainer.frame = bounds
        for r in rects {
            let radius = min(cornerRadius, r.height / 2)
            let bar = CALayer()
            bar.frame = r
            bar.backgroundColor = base
            bar.cornerRadius = radius
            barsLayer.addSublayer(bar)

            let maskBar = CALayer()
            maskBar.frame = r
            maskBar.backgroundColor = UIColor.white.cgColor
            maskBar.cornerRadius = radius
            maskContainer.addSublayer(maskBar)
        }
        shimmerLayer.frame = bounds
        shimmerLayer.mask = maskContainer
        CATransaction.commit()
    }

    /// 计算占位条矩形：UILabel → 逐行；其它 → 单条覆盖 bounds。
    private func barRects() -> [CGRect] {
        if let label = host as? UILabel, let text = label.attributedText ?? label.text.map({
            NSAttributedString(string: $0, attributes: [.font: label.font as Any]) }) {
            let lineRects = SkeletonLineLayout.lineRects(
                for: text, width: bounds.width,
                numberOfLines: label.numberOfLines,
                lineBreakMode: label.lineBreakMode)
            return lineRects.isEmpty ? [bounds] : lineRects
        }
        return [bounds]
    }

    /// ShimmerClock 每帧回调：phase 是高光带前缘的归一化位置；通过移动渐变的 start/endPoint
    /// 让 [clear, highlight, clear] 的高光从左扫到右（与 SwiftUI 实现一致）。layer 不动，故 mask 稳定。
    func applyShimmerPhase(_ phase: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shimmerLayer.startPoint = CGPoint(x: phase, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: phase + configuration.bandWidth, y: 0.5)
        CATransaction.commit()
    }
}
#endif
