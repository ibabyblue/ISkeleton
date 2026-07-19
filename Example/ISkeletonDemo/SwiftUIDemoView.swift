import SwiftUI
import SkeletonSwiftUI

/// Demonstrates environment-driven SwiftUI skeleton configuration and local overrides.
struct SwiftUIDemoView: View {
    /// The sweep direction selected by the control panel.
    @State private var direction: ShimmerDirection = .leftToRight
    /// The placeholder shape selected by the control panel.
    @State private var shape: DemoShape = .circle
    /// The color preset selected by the control panel.
    @State private var theme: DemoColorTheme = .default
    /// The sweep duration selected by the control panel, in seconds.
    @State private var duration: Double = 1.4
    /// The normalized highlight-band width selected by the control panel.
    @State private var bandWidth: Double = 0.6
    /// Whether the controlled examples currently display skeletons.
    @State private var isLoading = true

    /// The appearance derived from the current control-panel state.
    private var config: SkeletonConfiguration {
        SkeletonConfiguration(baseColor: theme.base,
                              highlightColor: theme.highlight,
                              duration: duration,
                              bandWidth: bandWidth,
                              cornerRadius: 5,
                              direction: direction)
    }

    /// The fixed warm appearance used to demonstrate a nested environment override.
    private let overrideConfig = SkeletonConfiguration(
        baseColor:      SkeletonRGBA(r: 0.96, g: 0.86, b: 0.86, a: 0.9),
        highlightColor: SkeletonRGBA(r: 1.0,  g: 0.95, b: 0.95, a: 0.95),
        duration: 1.0, bandWidth: 0.5, cornerRadius: 5, direction: .topLeftToBottomRight)

    /// The loaded content rendered beneath the controlled skeletons.
    private let sample = DemoProfile.samples[2]

    /// The scrollable SwiftUI lab and its environment-scoped appearance.
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    controlPanel
                    shapeExample
                    logoExample
                    profileCard
                    overrideCard
                }
                .padding()
            }
            .navigationTitle("SwiftUI")
        }
        .skeletonAppearance(config)   // Inject the panel configuration into the controlled subtree.
    }

    // MARK: - Control Panel

    /// The controls that update every public configuration value in real time.
    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Loading", isOn: $isLoading)
                .accessibilityIdentifier("example.swiftui.loading")

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

    /// Creates a labeled slider with a formatted live value.
    ///
    /// - Parameters:
    ///   - title: The short localized field title.
    ///   - value: The bound configuration value.
    ///   - range: The allowed closed value range.
    ///   - suffix: The unit suffix displayed after the formatted value.
    /// - Returns: A horizontal control row.
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

    // MARK: - Examples

    /// A block that switches among circle, capsule, and rounded-rectangle clipping.
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

    /// A centered SF Symbol whose alpha creates an image-masked skeleton.
    private var logoExample: some View {
        VStack(spacing: 8) {
            Text("加载 logo（图片蒙版）").font(.headline)
            Image(systemName: "swift")
                .resizable().scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.orange)
                .skeleton(isLoading, mask: Image(systemName: "swift"))
        }
        .frame(maxWidth: .infinity)
    }

    /// A profile card combining a circle, single-line labels, and multiline text bars.
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

    /// A card whose nested appearance remains independent of control-panel changes.
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
        .skeletonAppearance(overrideConfig)   // Override the configuration inherited from the panel.
    }
}
