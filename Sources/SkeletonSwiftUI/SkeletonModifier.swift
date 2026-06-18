import SwiftUI
import SkeletonCore

public extension View {
    /// active 时：隐藏真实内容但保留 footprint，叠加骨架占位；false 时原样显示。
    /// - shape: 图形占位形状（textStyle == nil 时生效，用于头像等）。
    /// - textStyle: 传入则按文本骨架渲染 —— 用该 TextStyle 的单行高度除 footprint 高度自动算行数（忽略 shape）。
    func skeleton(_ active: Bool,
                  shape: SkeletonShape = .roundedRect(cornerRadius: nil),
                  textStyle: Font.TextStyle? = nil) -> some View {
        modifier(SkeletonModifier(active: active, shape: shape, textStyle: textStyle))
    }

    /// active 时：隐藏内容，叠加 baseColor + 同相位高光，并用 image 的 alpha 作蒙版裁出轮廓。
    /// false 时：原样显示内容（如全彩 logo）。
    func skeleton(_ active: Bool, mask image: Image) -> some View {
        modifier(MaskedSkeletonModifier(active: active, maskImage: image))
    }
}

private struct SkeletonModifier: ViewModifier {
    let active: Bool
    let shape: SkeletonShape
    let textStyle: Font.TextStyle?
    @Environment(\.skeletonAppearance) private var config

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

private struct MaskedSkeletonModifier: ViewModifier {
    let active: Bool
    let maskImage: Image
    @Environment(\.skeletonAppearance) private var config

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

/// baseColor 填充 + 沿 direction 平移的高光带（几何/蒙版两条路径共用）。
func shimmerFill(config: SkeletonConfiguration, phase: CGFloat) -> some View {
    let pts = config.direction.gradientPoints(phase: phase, bandWidth: config.bandWidth)
    return config.baseColor.color.overlay {
        LinearGradient(colors: [.clear, config.highlightColor.color, .clear],
                       startPoint: UnitPoint(x: pts.start.x, y: pts.start.y),
                       endPoint: UnitPoint(x: pts.end.x, y: pts.end.y))
    }
}

/// 单条：按 shape 选原生形状，底色填充 + 同相位扫光。
private struct ShimmerSingle: View {
    let config: SkeletonConfiguration
    let shape: SkeletonShape

    var body: some View {
        TimelineView(.animation) { context in
            let phase = ShimmerPhase.phase(
                at: context.date.timeIntervalSinceReferenceDate,
                duration: config.duration, bandWidth: config.bandWidth)
            shaped(phase: phase)
        }
    }

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

    private func fill(phase: CGFloat) -> some View {
        shimmerFill(config: config, phase: phase)
    }
}

/// 多行文本骨架：用 SkeletonLineMetrics 由 footprint 高度自动算行数，每行占 lineHeight、
/// 条本体 ≈ 字形主体，顶对齐排列、底部余量留白；末行约 60% 宽，全部同相位扫光。
private struct ShimmerLines: View {
    let config: SkeletonConfiguration
    let lineHeight: CGFloat

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
