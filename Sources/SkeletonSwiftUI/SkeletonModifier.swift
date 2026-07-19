import SwiftUI
import SkeletonCore

/// Adds geometric and image-masked skeleton overlays to SwiftUI views.
public extension View {
    /// Replaces a view's visible content with an in-place skeleton while active.
    ///
    /// - Parameters:
    ///   - active: `true` to hide content while retaining its footprint and draw a skeleton.
    ///   - shape: The geometric placeholder shape used when `textStyle` is `nil`.
    ///   - textStyle: A text style used to derive multiline bar geometry. When non-`nil`, it overrides `shape`.
    /// - Returns: A view that conditionally renders the skeleton overlay.
    func skeleton(_ active: Bool,
                  shape: SkeletonShape = .roundedRect(cornerRadius: nil),
                  textStyle: Font.TextStyle? = nil) -> some View {
        modifier(SkeletonModifier(active: active, shape: shape, textStyle: textStyle))
    }

    /// Replaces a view's content with a shimmer clipped by an image's alpha channel.
    ///
    /// The real content remains in layout but is hidden while active. Deactivation
    /// restores the original content without changing its footprint.
    ///
    /// - Parameters:
    ///   - active: `true` to render the image-masked skeleton.
    ///   - image: The image whose alpha channel defines the visible shimmer silhouette.
    /// - Returns: A view that conditionally renders the masked skeleton.
    func skeleton(_ active: Bool, mask image: Image) -> some View {
        modifier(MaskedSkeletonModifier(active: active, maskImage: image))
    }
}

/// Renders a geometric or multiline placeholder over one hidden content view.
private struct SkeletonModifier: ViewModifier {
    /// Whether the placeholder replaces visible content.
    let active: Bool
    /// The shape used for non-text placeholders.
    let shape: SkeletonShape
    /// The text style used to derive multiline metrics, if requested.
    let textStyle: Font.TextStyle?
    /// The configuration inherited from the nearest appearance provider.
    @Environment(\.skeletonAppearance) private var config

    /// Conditionally hides content and overlays the appropriate placeholder renderer.
    ///
    /// - Parameter content: The original view content and its layout footprint.
    /// - Returns: The original content or its skeleton replacement.
    func body(content: Content) -> some View {
        if active {
            content.hidden().overlay {
                if let textStyle {
                    ShimmerLines(config: config,
                                 lineHeight: TextStyleMetrics.lineHeight(for: textStyle))
                } else {
                    ShimmerSingle(config: config, shape: shape)
                }
            }
        } else {
            content
        }
    }
}

/// Renders a shimmer clipped to a supplied SwiftUI image.
private struct MaskedSkeletonModifier: ViewModifier {
    /// Whether the masked placeholder replaces visible content.
    let active: Bool
    /// The image whose alpha channel clips the shimmer.
    let maskImage: Image
    /// The configuration inherited from the nearest appearance provider.
    @Environment(\.skeletonAppearance) private var config

    /// Conditionally hides content and overlays an image-masked animated fill.
    ///
    /// - Parameter content: The original content whose footprint is retained.
    /// - Returns: The original content or its masked skeleton replacement.
    func body(content: Content) -> some View {
        if active {
            content.hidden().overlay {
                TimelineView(.animation) { ctx in
                    let phase = ShimmerPhase.phase(
                        at: ctx.date.timeIntervalSinceReferenceDate,
                        duration: config.duration, bandWidth: config.bandWidth)
                    shimmerFill(config: config, phase: phase)
                        .mask(maskImage.resizable())
                }
            }
        } else {
            content
        }
    }
}

/// Builds the shared base fill and directional highlight used by all SwiftUI renderers.
///
/// - Parameters:
///   - config: The active colors, band width, and sweep direction.
///   - phase: The normalized leading-edge position for the current frame.
/// - Returns: A fill view before shape or image clipping is applied.
func shimmerFill(config: SkeletonConfiguration, phase: CGFloat) -> some View {
    let pts = config.direction.gradientPoints(phase: phase, bandWidth: config.bandWidth)
    return config.baseColor.color.overlay {
        LinearGradient(colors: [.clear, config.highlightColor.color, .clear],
                       startPoint: UnitPoint(x: pts.start.x, y: pts.start.y),
                       endPoint: UnitPoint(x: pts.end.x, y: pts.end.y))
    }
}

/// Renders one geometric placeholder using the shared animation phase.
private struct ShimmerSingle: View {
    /// The appearance and motion configuration for this placeholder.
    let config: SkeletonConfiguration
    /// The shape that clips the animated fill.
    let shape: SkeletonShape

    /// The continuously animated placeholder content.
    var body: some View {
        TimelineView(.animation) { context in
            let phase = ShimmerPhase.phase(
                at: context.date.timeIntervalSinceReferenceDate,
                duration: config.duration, bandWidth: config.bandWidth)
            shaped(phase: phase)
        }
    }

    /// Clips the animated fill to the selected native SwiftUI shape.
    ///
    /// - Parameter phase: The normalized leading-edge position for the current frame.
    /// - Returns: The clipped placeholder view.
    @ViewBuilder
    private func shaped(phase: CGFloat) -> some View {
        switch shape {
        case .circle:
            fill(phase: phase).clipShape(Circle())
        case .capsule:
            fill(phase: phase).clipShape(Capsule())
        case .roundedRect(let cr):
            fill(phase: phase).clipShape(RoundedRectangle(cornerRadius: cr ?? config.cornerRadius, style: .continuous))
        }
    }

    /// Creates the unshaped shimmer fill for one phase.
    ///
    /// - Parameter phase: The normalized leading-edge position for the current frame.
    /// - Returns: The shared shimmer fill view.
    private func fill(phase: CGFloat) -> some View {
        shimmerFill(config: config, phase: phase)
    }
}

/// Renders top-aligned multiline bars derived from the hidden content's footprint.
///
/// Every bar uses the same phase. The final bar uses 60 percent of the available
/// width when more than one line is present.
private struct ShimmerLines: View {
    /// The appearance and motion configuration shared by all bars.
    let config: SkeletonConfiguration
    /// The resolved dynamic line height used to calculate bar count and spacing.
    let lineHeight: CGFloat

    /// The multiline placeholder measured inside the hidden content footprint.
    var body: some View {
        GeometryReader { geo in
            let n = SkeletonLineMetrics.lineCount(height: geo.size.height, lineHeight: lineHeight)
            let barH = SkeletonLineMetrics.barHeight(lineHeight: lineHeight)
            let gap = max(0, lineHeight - barH)
            TimelineView(.animation) { context in
                let phase = ShimmerPhase.phase(
                    at: context.date.timeIntervalSinceReferenceDate,
                    duration: config.duration, bandWidth: config.bandWidth)
                VStack(alignment: .leading, spacing: gap) {
                    ForEach(0..<n, id: \.self) { i in
                        bar(width: (n > 1 && i == n - 1) ? geo.size.width * 0.6 : geo.size.width,
                            height: barH, phase: phase)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
    }

    /// Builds one clipped shimmer bar and fills the remaining row width with space.
    ///
    /// - Parameters:
    ///   - width: The visible bar width, in points.
    ///   - height: The visible bar height, in points.
    ///   - phase: The normalized leading-edge position for the current frame.
    /// - Returns: A leading-aligned bar row.
    private func bar(width: CGFloat, height: CGFloat, phase: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: min(config.cornerRadius, height / 2), style: .continuous)
        let pts = config.direction.gradientPoints(phase: phase, bandWidth: config.bandWidth)
        return HStack(spacing: 0) {
            config.baseColor.color
                .overlay {
                    LinearGradient(colors: [.clear, config.highlightColor.color, .clear],
                                   startPoint: UnitPoint(x: pts.start.x, y: pts.start.y),
                                   endPoint: UnitPoint(x: pts.end.x, y: pts.end.y))
                }
                .frame(width: width, height: height)
                .clipShape(shape)
            Spacer(minLength: 0)
        }
    }
}
