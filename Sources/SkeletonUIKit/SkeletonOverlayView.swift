#if canImport(UIKit)
import UIKit
import SkeletonCore

/// 覆盖在 host 上的扫光占位层。不参与 host 的 intrinsic size；尺寸跟随 host bounds。
final class SkeletonOverlayView: UIView, ShimmerDriven {

    /// 单个占位条的几何：矩形 + 圆角。
    private struct Bar { let rect: CGRect; let radius: CGFloat }

    let configuration: SkeletonConfiguration
    private let shape: SkeletonShape
    /// 逐行条相对行高的高度比例（留出行间隔）。
    private let lineFillRatio: CGFloat = 0.62
    /// 弱引用 host，用于读取 UILabel 的文案排版信息。
    private weak var host: UIView?

    private let barsLayer = CALayer()
    private let shimmerLayer = CAGradientLayer()
    private var lastBuiltSize: CGSize = .zero

    init(host: UIView, configuration: SkeletonConfiguration, shape: SkeletonShape) {
        self.host = host
        self.configuration = configuration
        self.shape = shape
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

    /// 测试用：当前占位条数量 / frame / 圆角。
    var builtBarCountForTesting: Int { barsLayer.sublayers?.count ?? 0 }
    var builtBarFramesForTesting: [CGRect] { (barsLayer.sublayers ?? []).map { $0.frame } }
    var builtBarRadiiForTesting: [CGFloat] { (barsLayer.sublayers ?? []).map { $0.cornerRadius } }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastBuiltSize, !bounds.isEmpty else { return }
        lastBuiltSize = bounds.size
        rebuildBars()
    }

    private func rebuildBars() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        barsLayer.frame = bounds
        barsLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let base = configuration.baseColor.uiColor.cgColor
        let maskContainer = CALayer()
        maskContainer.frame = bounds
        for bar in barSpecs() {
            let layerBar = CALayer()
            layerBar.frame = bar.rect
            layerBar.backgroundColor = base
            layerBar.cornerRadius = bar.radius
            barsLayer.addSublayer(layerBar)

            let maskBar = CALayer()
            maskBar.frame = bar.rect
            maskBar.backgroundColor = UIColor.white.cgColor
            maskBar.cornerRadius = bar.radius
            maskContainer.addSublayer(maskBar)
        }
        shimmerLayer.frame = bounds
        shimmerLayer.mask = maskContainer
        CATransaction.commit()
    }

    /// UILabel → 逐行（每条按行高收缩、垂直居中，留出间隔）；其它 → 单条覆盖 bounds（用 shape 圆角）。
    private func barSpecs() -> [Bar] {
        if let label = host as? UILabel, let text = labelText(label) {
            let lineRects = SkeletonLineLayout.lineRects(
                for: text, width: bounds.width,
                numberOfLines: label.numberOfLines,
                lineBreakMode: label.lineBreakMode)
            if !lineRects.isEmpty {
                return lineRects.map { line in
                    let h = line.height * lineFillRatio
                    let rect = CGRect(x: line.minX, y: line.midY - h / 2, width: line.width, height: h)
                    return Bar(rect: rect, radius: min(configuration.cornerRadius, h / 2))
                }
            }
        }
        let radius = shape.cornerRadius(for: bounds.size, default: configuration.cornerRadius)
        return [Bar(rect: bounds, radius: radius)]
    }

    private func labelText(_ label: UILabel) -> NSAttributedString? {
        if let attr = label.attributedText { return attr }
        if let t = label.text { return NSAttributedString(string: t, attributes: [.font: label.font as Any]) }
        return nil
    }

    func applyShimmerPhase(_ phase: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shimmerLayer.startPoint = CGPoint(x: phase, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: phase + configuration.bandWidth, y: 0.5)
        CATransaction.commit()
    }
}
#endif
