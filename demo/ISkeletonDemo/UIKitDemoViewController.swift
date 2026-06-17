import UIKit
import SwiftUI
import SkeletonUIKit

/// 把 UIKit 演示 VC 包进 SwiftUI 的 TabView。
struct UIKitDemoScreen: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: UIKitDemoViewController())
    }
    func updateUIViewController(_ vc: UINavigationController, context: Context) {}
}

/// UIKit 演示：顶部原生控制面板驱动全局 `Skeleton.appearance`（方向/形状/主题/时长/带宽），
/// 改任一项走 `applyConfig()` —— 遵守快照契约：先 `skeleton(false)` 再（loading 时）`skeleton(true)`。
/// 末尾「per-call 覆盖」label 始终传 `appearance:` 固定异色，演示 UIKit 专有的单次覆盖。
final class UIKitDemoViewController: UIViewController {
    // 面板状态
    private var direction: ShimmerDirection = .leftToRight
    private var demoShape: DemoShape = .circle
    private var theme: DemoColorTheme = .default
    private var duration: Double = 1.4
    private var bandWidth: Double = 0.6
    private var isLoading = true

    // 控件
    private let loadingSwitch = UISwitch()
    private let directionButton = UIButton(type: .system)
    private let shapeSeg = UISegmentedControl(items: DemoShape.allCases.map(\.title))
    private let themeSeg = UISegmentedControl(items: DemoColorTheme.allCases.map(\.title))
    private let durationSlider = UISlider()
    private let bandWidthSlider = UISlider()

    // 受控内容
    private let shapeBox = UIView()
    private var shapeBoxWidth: NSLayoutConstraint!
    private let avatar = UIView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let bioLabel = UILabel()
    private let overrideLabel = UILabel()

    /// per-call 覆盖固定外观（不随面板变）。
    private let overrideConfig = SkeletonConfiguration(
        baseColor:      SkeletonRGBA(r: 0.96, g: 0.86, b: 0.86, a: 0.9),
        highlightColor: SkeletonRGBA(r: 1.0,  g: 0.95, b: 0.95, a: 0.95),
        duration: 1.0, bandWidth: 0.5, cornerRadius: 5, direction: .topLeftToBottomRight)

    private var config: SkeletonConfiguration {
        SkeletonConfiguration(baseColor: theme.base, highlightColor: theme.highlight,
                              duration: duration, bandWidth: bandWidth,
                              cornerRadius: 5, direction: direction)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit"
        view.backgroundColor = .systemBackground
        buildLayout()
        configureControls()
        seedContentText()           // 代表性文案先就位（撑尺寸/行数），再激活骨架
        applyConfig()
    }

    // MARK: - 布局

    private func buildLayout() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let root = UIStackView(arrangedSubviews: [
            controlPanel(), shapeSection(), profileCard(), overrideCard(),
        ])
        root.axis = .vertical
        root.spacing = 20
        root.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(root)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            root.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            root.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
            root.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            root.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

    private func controlPanel() -> UIView {
        let loadingRow = labeledRow("Loading", loadingSwitch)
        let directionRow = labeledRow("方向", directionButton)
        let durationRow = labeledRow("时长", durationSlider)
        let bandRow = labeledRow("带宽", bandWidthSlider)

        let stack = UIStackView(arrangedSubviews: [
            loadingRow, directionRow, shapeSeg, themeSeg, durationRow, bandRow,
        ])
        stack.axis = .vertical
        stack.spacing = 12
        return card(wrapping: stack)
    }

    private func shapeSection() -> UIView {
        let title = sectionTitle("形状")
        shapeBox.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        shapeBox.translatesAutoresizingMaskIntoConstraints = false
        shapeBoxWidth = shapeBox.widthAnchor.constraint(equalToConstant: 64)
        NSLayoutConstraint.activate([shapeBoxWidth, shapeBox.heightAnchor.constraint(equalToConstant: 64)])
        let row = UIStackView(arrangedSubviews: [shapeBox, UIView()])
        row.axis = .horizontal
        let stack = UIStackView(arrangedSubviews: [title, row])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    private func profileCard() -> UIView {
        avatar.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        avatar.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = .preferredFont(forTextStyle: .headline)
        priceLabel.font = .preferredFont(forTextStyle: .subheadline)
        priceLabel.textColor = .systemPink
        bioLabel.font = .preferredFont(forTextStyle: .footnote)
        bioLabel.textColor = .secondaryLabel
        bioLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [nameLabel, priceLabel, bioLabel])
        textStack.axis = .vertical
        textStack.spacing = 8

        let row = UIStackView(arrangedSubviews: [avatar, textStack])
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 12

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 56),
            avatar.heightAnchor.constraint(equalToConstant: 56),
        ])
        return card(wrapping: row)
    }

    private func overrideCard() -> UIView {
        let title = sectionTitle("per-call 覆盖（不随面板变）")
        overrideLabel.font = .preferredFont(forTextStyle: .footnote)
        overrideLabel.textColor = .secondaryLabel
        overrideLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [title, overrideLabel])
        stack.axis = .vertical
        stack.spacing = 8
        return card(wrapping: stack)
    }

    // MARK: - 控件配置

    private func configureControls() {
        loadingSwitch.isOn = isLoading
        loadingSwitch.addTarget(self, action: #selector(loadingChanged), for: .valueChanged)

        directionButton.showsMenuAsPrimaryAction = true
        directionButton.menu = buildDirectionMenu()
        updateDirectionTitle()

        shapeSeg.selectedSegmentIndex = DemoShape.allCases.firstIndex(of: demoShape) ?? 0
        shapeSeg.addTarget(self, action: #selector(shapeChanged), for: .valueChanged)

        themeSeg.selectedSegmentIndex = DemoColorTheme.allCases.firstIndex(of: theme) ?? 0
        themeSeg.addTarget(self, action: #selector(themeChanged), for: .valueChanged)

        durationSlider.minimumValue = 0.4
        durationSlider.maximumValue = 3.0
        durationSlider.value = Float(duration)
        durationSlider.addTarget(self, action: #selector(durationChanged), for: .valueChanged)

        bandWidthSlider.minimumValue = 0.1
        bandWidthSlider.maximumValue = 1.0
        bandWidthSlider.value = Float(bandWidth)
        bandWidthSlider.addTarget(self, action: #selector(bandWidthChanged), for: .valueChanged)
    }

    private func buildDirectionMenu() -> UIMenu {
        let actions = ShimmerDirection.allCases.map { d in
            UIAction(title: demoDirectionTitle(d), state: d == direction ? .on : .off) { [weak self] _ in
                self?.direction = d
                self?.directionButton.menu = self?.buildDirectionMenu()   // 刷新勾选
                self?.updateDirectionTitle()
                self?.applyConfig()
            }
        }
        return UIMenu(children: actions)
    }

    private func updateDirectionTitle() {
        directionButton.setTitle(demoDirectionTitle(direction) + " ▾", for: .normal)
    }

    private func seedContentText() {
        let p = DemoProfile.samples[2]
        nameLabel.text = p.name
        priceLabel.text = p.price
        bioLabel.text = p.bio
        overrideLabel.text = "这段始终用固定暖色 + 左上→右下 扫光，与上面面板互不影响。"
    }

    // MARK: - 应用配置（核心）

    /// 设全局外观，并按快照契约重建所有受控骨架。
    private func applyConfig() {
        Skeleton.appearance = config
        shapeBoxWidth.constant = (demoShape == .circle) ? 64 : 200

        // 主 slot：用全局 Skeleton.appearance。先关再开方能应用新配置（激活时快照）。
        rebuild(shapeBox, shape: demoShape.skeletonShape)
        rebuild(avatar, shape: .circle)
        rebuild(nameLabel)
        rebuild(priceLabel)
        rebuild(bioLabel)
        // per-call 覆盖：固定 overrideConfig，不受面板影响。
        rebuild(overrideLabel, appearance: overrideConfig)
    }

    private func rebuild(_ v: UIView,
                         shape: SkeletonShape = .roundedRect(cornerRadius: nil),
                         appearance: SkeletonConfiguration? = nil) {
        v.skeleton(false)
        if isLoading { v.skeleton(true, shape: shape, appearance: appearance) }
    }

    // MARK: - 回调

    @objc private func loadingChanged()  { isLoading = loadingSwitch.isOn; applyConfig() }
    @objc private func shapeChanged()    { demoShape = DemoShape.allCases[shapeSeg.selectedSegmentIndex]; applyConfig() }
    @objc private func themeChanged()    { theme = DemoColorTheme.allCases[themeSeg.selectedSegmentIndex]; applyConfig() }
    @objc private func durationChanged() { duration = Double(durationSlider.value); applyConfig() }
    @objc private func bandWidthChanged(){ bandWidth = Double(bandWidthSlider.value); applyConfig() }

    // MARK: - 小工具

    private func sectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .headline)
        l.text = text
        l.numberOfLines = 0
        return l
    }

    private func labeledRow(_ title: String, _ control: UIView) -> UIStackView {
        let l = UILabel()
        l.text = title
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.setContentHuggingPriority(.required, for: .horizontal)
        control.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [l, control])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        return row
    }

    private func card(wrapping content: UIView) -> UIView {
        let bg = UIView()
        bg.backgroundColor = .secondarySystemBackground
        bg.layer.cornerRadius = 12
        content.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: bg.topAnchor, constant: 12),
            content.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 12),
            content.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -12),
            content.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -12),
        ])
        return bg
    }
}
