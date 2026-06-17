import SwiftUI
import SkeletonSwiftUI

/// SwiftUI 演示：顶部实时控制面板驱动一套 `SkeletonConfiguration`（方向/形状/主题/时长/带宽），
/// 经 `.skeletonAppearance(config)` 注入子树；下方各 slot 用 `.skeleton(isLoading, …)`。
/// 末尾「局部覆盖卡」用独立 `.skeletonAppearance` 演示子树覆盖——不随面板变。
struct SwiftUIDemoView: View {
    @State private var direction: ShimmerDirection = .leftToRight
    @State private var shape: DemoShape = .circle
    @State private var theme: DemoColorTheme = .default
    @State private var duration: Double = 1.4
    @State private var bandWidth: Double = 0.6
    @State private var isLoading = true

    /// 面板派生的外观。
    private var config: SkeletonConfiguration {
        SkeletonConfiguration(baseColor: theme.base,
                              highlightColor: theme.highlight,
                              duration: duration,
                              bandWidth: bandWidth,
                              cornerRadius: 5,
                              direction: direction)
    }

    /// 局部覆盖示例固定使用的暖色外观（不随面板变）。
    private let overrideConfig = SkeletonConfiguration(
        baseColor:      SkeletonRGBA(r: 0.96, g: 0.86, b: 0.86, a: 0.9),
        highlightColor: SkeletonRGBA(r: 1.0,  g: 0.95, b: 0.95, a: 0.95),
        duration: 1.0, bandWidth: 0.5, cornerRadius: 5, direction: .topLeftToBottomRight)

    private let sample = DemoProfile.samples[2]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    controlPanel
                    shapeExample
                    profileCard
                    overrideCard
                }
                .padding()
            }
            .navigationTitle("SwiftUI")
        }
        .skeletonAppearance(config)   // 面板配置注入整棵受控子树
    }

    // MARK: - 控制面板

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Loading", isOn: $isLoading)

            Picker("方向", selection: $direction) {
                ForEach(ShimmerDirection.allCases, id: \.self) { d in
                    Text(demoDirectionTitle(d)).tag(d)
                }
            }

            Picker("形状", selection: $shape) {
                ForEach(DemoShape.allCases) { s in Text(s.title).tag(s) }
            }
            .pickerStyle(.segmented)

            Picker("主题", selection: $theme) {
                ForEach(DemoColorTheme.allCases) { t in Text(t.title).tag(t) }
            }
            .pickerStyle(.segmented)

            slider(title: "时长", value: $duration, range: 0.4...3.0, suffix: "s")
            slider(title: "带宽", value: $bandWidth, range: 0.1...1.0, suffix: "")
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    private func slider(title: String, value: Binding<Double>,
                        range: ClosedRange<Double>, suffix: String) -> some View {
        HStack {
            Text(title).frame(width: 36, alignment: .leading)
            Slider(value: value, in: range)
            Text(String(format: "%.2f", value.wrappedValue) + suffix)
                .font(.caption.monospacedDigit())
                .frame(width: 48, alignment: .trailing)
        }
    }

    // MARK: - 示例

    /// 形状示例块：随面板「形状」切换 circle / capsule / roundedRect。
    private var shapeExample: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("形状").font(.headline)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: shape == .circle ? 64 : 160, height: 64)
                .skeleton(isLoading, shape: shape.skeletonShape)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 资料卡：圆头像 + 单行 name/price + 多行 bio（textStyle 自动算行数）。
    private var profileCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().fill(Color.gray.opacity(0.2)).frame(width: 56, height: 56)
                .skeleton(isLoading, shape: .circle)
            VStack(alignment: .leading, spacing: 8) {
                Text(sample.name).font(.headline)
                    .skeleton(isLoading)
                Text(sample.price).font(.subheadline).foregroundStyle(.pink)
                    .skeleton(isLoading)
                Text(sample.bio).font(.footnote).foregroundStyle(.secondary)
                    .skeleton(isLoading, textStyle: .footnote)
            }
            Spacer(minLength: 0)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }

    /// 局部覆盖卡：内部子树注入固定 `overrideConfig`，演示「子树覆盖全局/面板外观」。
    private var overrideCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("局部覆盖（不随面板变）").font(.headline)
            Text("这段始终用固定暖色 + 左上→右下 扫光")
                .font(.footnote).foregroundStyle(.secondary)
                .skeleton(isLoading, textStyle: .footnote)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        .skeletonAppearance(overrideConfig)   // 覆盖父级面板注入的 config
    }
}
