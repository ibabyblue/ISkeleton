import SwiftUI
import SkeletonCore

public extension View {
    /// active 时：隐藏真实内容但保留其 footprint，叠加圆角扫光占位；false 时原样显示真实内容。
    /// cornerRadius 为 nil 时取外观配置的 cornerRadius。
    func skeleton(_ active: Bool, cornerRadius: CGFloat? = nil) -> some View {
        modifier(SkeletonModifier(active: active, cornerRadius: cornerRadius))
    }
}

private struct SkeletonModifier: ViewModifier {
    let active: Bool
    let cornerRadius: CGFloat?
    @Environment(\.skeletonAppearance) private var config

    func body(content: Content) -> some View {
        if active {
            content
                .hidden()
                .overlay { ShimmerPlaceholder(config: config, cornerRadius: cornerRadius ?? config.cornerRadius) }
        } else {
            content
        }
    }
}

/// 圆角底色 + 同相位移动高光带。
private struct ShimmerPlaceholder: View {
    let config: SkeletonConfiguration
    let cornerRadius: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        TimelineView(.animation) { context in
            let phase = ShimmerPhase.phase(
                at: context.date.timeIntervalSinceReferenceDate,
                duration: config.duration,
                bandWidth: config.bandWidth
            )
            shape
                .fill(config.baseColor.color)
                .overlay {
                    LinearGradient(
                        colors: [.clear, config.highlightColor.color, .clear],
                        startPoint: UnitPoint(x: phase, y: 0.5),
                        endPoint: UnitPoint(x: phase + config.bandWidth, y: 0.5)
                    )
                }
                .clipShape(shape)
        }
    }
}
