#if canImport(UIKit)
import UIKit
import SkeletonCore

/// Displays content-driven skeleton bars or an image-masked shimmer without affecting host layout.
final class SkeletonOverlayView: UIView, ShimmerDriven {

    /// The frame and corner radius of one placeholder bar.
    private struct Bar {
        /// The bar frame in overlay coordinates.
        let rect: CGRect;
        /// The corner radius applied to the bar and its shimmer mask.
        let radius: CGFloat
    }

    /// The immutable configuration snapshotted when the overlay is created.
    let configuration: SkeletonConfiguration
    /// The geometric shape used when the host does not produce multiline label bars.
    private let shape: SkeletonShape
    /// The optional image that clips the entire base and highlight fill by alpha.
    private let maskImage: CGImage?
    /// The portion of a UIKit line fragment occupied by its visible bar.
    private let lineFillRatio: CGFloat = 0.62
    /// The weak host used to inspect label text layout without creating a view cycle.
    private weak var host: UIView?

    /// Contains the base-color layers for geometric bars or an image fill.
    private let barsLayer = CALayer()
    /// Draws the moving highlight and is clipped to current placeholder geometry.
    private let shimmerLayer = CAGradientLayer()
    /// The last nonempty bounds size used to build layer geometry.
    private var lastBuiltSize: CGSize = .zero

    /// Creates an overlay that follows a host's bounds and snapshots one configuration.
    ///
    /// - Parameters:
    ///   - host: The view whose bounds and optional label layout define the placeholder.
    ///   - configuration: The immutable appearance and motion values for this activation.
    ///   - shape: The fallback geometric shape for non-label hosts.
    ///   - maskImage: An optional bitmap alpha mask. The default is `nil`.
    init(host: UIView, configuration: SkeletonConfiguration, shape: SkeletonShape,
         maskImage: CGImage? = nil) {
        self.host = host
        self.configuration = configuration
        self.shape = shape
        self.maskImage = maskImage
        super.init(frame: host.bounds)
        isUserInteractionEnabled = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        layer.addSublayer(barsLayer)

        shimmerLayer.colors = [UIColor.clear.cgColor,
                               configuration.highlightColor.uiColor.cgColor,
                               UIColor.clear.cgColor]
        let initialPoints = configuration.direction.gradientPoints(
            phase: -configuration.bandWidth, bandWidth: configuration.bandWidth)
        shimmerLayer.startPoint = initialPoints.start
        shimmerLayer.endPoint = initialPoints.end
        layer.addSublayer(shimmerLayer)
    }

    /// Storyboard and archive construction are unavailable for programmatic overlays.
    ///
    /// - Parameter coder: The decoder supplied by UIKit.
    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// The configuration used by the shared shimmer clock for phase calculation.
    var shimmerConfiguration: SkeletonConfiguration { configuration }

    /// The number of currently built base bars, exposed for tests.
    var builtBarCountForTesting: Int { barsLayer.sublayers?.count ?? 0 }
    /// The frames of currently built base bars, exposed for tests.
    var builtBarFramesForTesting: [CGRect] { (barsLayer.sublayers ?? []).map { $0.frame } }
    /// The corner radii of currently built base bars, exposed for tests.
    var builtBarRadiiForTesting: [CGFloat] { (barsLayer.sublayers ?? []).map { $0.cornerRadius } }
    /// The current gradient frame in overlay coordinates, exposed for tests.
    var shimmerRenderingFrameForTesting: CGRect { shimmerLayer.frame }
    /// The current shimmer-mask bar frames converted to overlay coordinates, exposed for tests.
    var shimmerMaskBarFramesForTesting: [CGRect] {
        (shimmerLayer.mask?.sublayers ?? []).map { maskBar in
            maskBar.frame.offsetBy(
                dx: shimmerLayer.frame.minX,
                dy: shimmerLayer.frame.minY
            )
        }
    }
    /// Whether an image mask currently clips the overlay, exposed for tests.
    var isImageMaskedForTesting: Bool { layer.mask != nil }

    /// Rebuilds placeholder layers when the overlay receives a new nonempty size.
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastBuiltSize, !bounds.isEmpty else { return }
        lastBuiltSize = bounds.size
        rebuildBars()
    }

    /// Recreates geometric bars across their shared rendering extent or delegates to image-mask construction.
    private func rebuildBars() {
        if let maskImage {
            rebuildImageMasked(maskImage)
            return
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        barsLayer.frame = bounds
        barsLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let base = configuration.baseColor.uiColor.cgColor
        let bars = barSpecs()
        let renderingFrame = bars.reduce(bounds) { frame, bar in
            frame.union(bar.rect)
        }
        let maskContainer = CALayer()
        maskContainer.frame = CGRect(origin: .zero, size: renderingFrame.size)
        for bar in bars {
            let layerBar = CALayer()
            layerBar.frame = bar.rect
            layerBar.backgroundColor = base
            layerBar.cornerRadius = bar.radius
            barsLayer.addSublayer(layerBar)

            let maskBar = CALayer()
            maskBar.frame = bar.rect.offsetBy(
                dx: -renderingFrame.minX,
                dy: -renderingFrame.minY
            )
            maskBar.backgroundColor = UIColor.white.cgColor
            maskBar.cornerRadius = bar.radius
            maskContainer.addSublayer(maskBar)
        }
        shimmerLayer.frame = renderingFrame
        shimmerLayer.mask = maskContainer
        CATransaction.commit()
    }

    /// Fills the bounds and clips the combined base and highlight through image alpha.
    ///
    /// - Parameter image: The bitmap assigned to the overlay layer mask.
    private func rebuildImageMasked(_ image: CGImage) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        barsLayer.frame = bounds
        barsLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let fill = CALayer()
        fill.frame = bounds
        fill.backgroundColor = configuration.baseColor.uiColor.cgColor
        barsLayer.addSublayer(fill)

        shimmerLayer.frame = bounds
        shimmerLayer.mask = nil   // Fill all bounds; the outer image mask performs final clipping.

        let m = CALayer()
        m.frame = bounds
        m.contents = image
        m.contentsGravity = .resizeAspect
        layer.mask = m
        CATransaction.commit()
    }

    /// Calculates text-driven label bars or one bounds-filling geometric bar.
    ///
    /// Label bars are vertically centered within each content-driven line fragment
    /// and reduced by `lineFillRatio`. Empty or unavailable label layout falls back
    /// to one shape bar.
    ///
    /// - Returns: The bar geometry used to build fill and shimmer-mask layers.
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

    /// Resolves a label's attributed or plain text with the font required by TextKit.
    ///
    /// - Parameter label: The label whose current content defines line geometry.
    /// - Returns: Attributed text suitable for layout, or `nil` when the label has no text.
    private func labelText(_ label: UILabel) -> NSAttributedString? {
        if let attr = label.attributedText { return attr }
        if let t = label.text { return NSAttributedString(string: t, attributes: [.font: label.font as Any]) }
        return nil
    }

    /// Updates the gradient endpoints for one shared-clock frame without implicit animation.
    ///
    /// - Parameter phase: The normalized position of the highlight band's leading edge.
    func applyShimmerPhase(_ phase: CGFloat) {
        let pts = configuration.direction.gradientPoints(phase: phase, bandWidth: configuration.bandWidth)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shimmerLayer.startPoint = pts.start
        shimmerLayer.endPoint = pts.end
        CATransaction.commit()
    }
}
#endif
