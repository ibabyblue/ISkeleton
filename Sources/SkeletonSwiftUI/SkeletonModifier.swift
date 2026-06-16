import SwiftUI
import SkeletonCore

public extension View {
    /// active 时：隐藏真实内容但保留 footprint，叠加骨架占位；false 时原样显示。
    /// - shape: 单条形状（lines<=1 时生效）。
    /// - lines: >1 时按多行渲染（忽略 shape，画 lines 条带间隔的圆角条，末行较短）。
    func skeleton(_ active: Bool,
                  shape: SkeletonShape = .roundedRect(cornerRadius: nil),
                  lines: Int = 1) -> some View {
        modifier(SkeletonModifier(active: active, shape: shape, lines: lines))
    }
}

private struct SkeletonModifier: ViewModifier {
    let active: Bool
    let shape: SkeletonShape
    let lines: Int
    @Environment(\.skeletonAppearance) private var config

    func body(content: Content) -> some View {
        if active {
            content.hidden().overlay {
                if lines > 1 {
                    ShimmerLines(config: config, lines: lines)
                } else {
                    ShimmerSingle(config: config, shape: shape)
                }
            }
        } else {
            content
        }
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
        config.baseColor.color.overlay {
            LinearGradient(colors: [.clear, config.highlightColor.color, .clear],
                           startPoint: UnitPoint(x: phase, y: 0.5),
                           endPoint: UnitPoint(x: phase + config.bandWidth, y: 0.5))
        }
    }
}

/// 多行：把 footprint 高度均分为 lines 条圆角条，带间隔、末行约 60% 宽，全部同相位扫光。
private struct ShimmerLines: View {
    let config: SkeletonConfiguration
    let lines: Int

    var body: some View {
        GeometryReader { geo in
            let n = max(1, lines)
            let gapRatio: CGFloat = 0.35
            let barH = geo.size.height / (CGFloat(n) + gapRatio * CGFloat(n - 1))
            let gap = barH * gapRatio
            TimelineView(.animation) { context in
                let phase = ShimmerPhase.phase(
                    at: context.date.timeIntervalSinceReferenceDate,
                    duration: config.duration, bandWidth: config.bandWidth)
                VStack(spacing: gap) {
                    ForEach(0..<n, id: \.self) { i in
                        bar(width: i == n - 1 ? geo.size.width * 0.6 : geo.size.width,
                            height: barH, phase: phase)
                    }
                }
            }
        }
    }

    private func bar(width: CGFloat, height: CGFloat, phase: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: min(config.cornerRadius, height / 2), style: .continuous)
        return HStack(spacing: 0) {
            config.baseColor.color
                .overlay {
                    LinearGradient(colors: [.clear, config.highlightColor.color, .clear],
                                   startPoint: UnitPoint(x: phase, y: 0.5),
                                   endPoint: UnitPoint(x: phase + config.bandWidth, y: 0.5))
                }
                .frame(width: width, height: height)
                .clipShape(shape)
            Spacer(minLength: 0)
        }
    }
}
