import UIKit
import SwiftUI
import AVFoundation
import SkeletonUIKit

/// Hosts the UIKit lab inside the Example's SwiftUI tab hierarchy.
struct UIKitDemoScreen: UIViewControllerRepresentable {
    /// Creates the navigation controller that owns the UIKit demonstration view controller.
    ///
    /// - Parameter context: The representable context supplied by SwiftUI.
    /// - Returns: A navigation controller rooted at the UIKit lab.
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: UIKitDemoViewController())
    }
    /// Accepts SwiftUI updates; the UIKit lab owns its state and requires no synchronization.
    ///
    /// - Parameters:
    ///   - vc: The existing navigation controller.
    ///   - context: The representable context supplied by SwiftUI.
    func updateUIViewController(_ vc: UINavigationController, context: Context) {}
}

/// Demonstrates global UIKit appearance, activation snapshots, and per-call overrides.
final class UIKitDemoViewController: UIViewController {
    // Control-panel state
    /// The selected shimmer sweep direction.
    private var direction: ShimmerDirection = .leftToRight
    /// The selected picker-friendly placeholder shape.
    private var demoShape: DemoShape = .circle
    /// The selected skeleton color preset.
    private var theme: DemoColorTheme = .default
    /// The selected sweep duration, in seconds.
    private var duration: Double = 1.4
    /// The selected normalized highlight-band width.
    private var bandWidth: Double = 0.6
    /// Whether the controlled UIKit slots currently display skeletons.
    private var isLoading = true

    // Controls
    /// Toggles the loading state for every controlled slot.
    private let loadingSwitch = UISwitch()
    /// Opens the menu containing all eight shimmer directions.
    private let directionButton = UIButton(type: .system)
    /// Selects the geometric placeholder shape.
    private let shapeSeg = UISegmentedControl(items: DemoShape.allCases.map(\.title))
    /// Selects the global color preset.
    private let themeSeg = UISegmentedControl(items: DemoColorTheme.allCases.map(\.title))
    /// Selects the global sweep duration.
    private let durationSlider = UISlider()
    /// Selects the global normalized highlight-band width.
    private let bandWidthSlider = UISlider()

    // Controlled content
    /// The fixed-height block used to demonstrate shape switching.
    private let shapeBox = UIView()
    /// The width constraint adjusted when the selected shape changes.
    private var shapeBoxWidth: NSLayoutConstraint!
    /// The fixed-size profile avatar skeleton host.
    private let avatar = UIView()
    /// The single-line profile name label.
    private let nameLabel = UILabel()
    /// The single-line profile price label.
    private let priceLabel = UILabel()
    /// The unlimited-line profile biography label.
    private let bioLabel = UILabel()
    /// The label that always uses a per-activation appearance override.
    private let overrideLabel = UILabel()
    /// The image view used to demonstrate `.ownImage` alpha masking.
    private let logoView = UIImageView()

    /// Rasterizes the Swift SF Symbol into the bitmap alpha required by UIKit masking.
    ///
    /// - Returns: An 80-point bitmap image with transparent background pixels.
    private func rasterizedLogo() -> UIImage {
        let cfg = UIImage.SymbolConfiguration(pointSize: 64, weight: .bold)
        let symbol = UIImage(systemName: "swift", withConfiguration: cfg)!
            .withTintColor(.label, renderingMode: .alwaysOriginal)
        let size = CGSize(width: 80, height: 80)
        return UIGraphicsImageRenderer(size: size).image { _ in
            let r = AVMakeRect(aspectRatio: symbol.size, insideRect: CGRect(origin: .zero, size: size))
            symbol.draw(in: r)
        }
    }

    /// The fixed per-activation appearance that ignores global control-panel changes.
    private let overrideConfig = SkeletonConfiguration(
        baseColor:      SkeletonRGBA(r: 0.96, g: 0.86, b: 0.86, a: 0.9),
        highlightColor: SkeletonRGBA(r: 1.0,  g: 0.95, b: 0.95, a: 0.95),
        duration: 1.0, bandWidth: 0.5, cornerRadius: 5, direction: .topLeftToBottomRight)

    /// The global UIKit appearance derived from the current control-panel state.
    private var config: SkeletonConfiguration {
        SkeletonConfiguration(baseColor: theme.base, highlightColor: theme.highlight,
                              duration: duration, bandWidth: bandWidth,
                              cornerRadius: 5, direction: direction)
    }

    /// Builds the lab, seeds representative content, and activates initial skeletons.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit"
        view.backgroundColor = .systemBackground
        buildLayout()
        configureControls()
        seedContentText()           // Reserve representative size and lines before activation.
        applyConfig()
    }

    // MARK: - Layout

    /// Creates the scroll view and vertical stack containing every UIKit scenario.
    private func buildLayout() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let root = UIStackView(arrangedSubviews: [
            controlPanel(), shapeSection(), logoSection(), profileCard(), overrideCard(),
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

    /// Creates the card containing all global configuration controls.
    ///
    /// - Returns: The styled control-panel container.
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

    /// Creates the geometric shape demonstration section.
    ///
    /// - Returns: A titled shape host and flexible trailing space.
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

    /// Creates the rasterized-logo image-mask demonstration section.
    ///
    /// - Returns: A titled logo host and flexible trailing space.
    private func logoSection() -> UIView {
        let title = sectionTitle("加载 logo（图片蒙版）")
        logoView.image = rasterizedLogo()
        logoView.contentMode = .scaleAspectFit
        logoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoView.widthAnchor.constraint(equalToConstant: 80),
            logoView.heightAnchor.constraint(equalToConstant: 80),
        ])
        let row = UIStackView(arrangedSubviews: [logoView, UIView()])
        row.axis = .horizontal
        let stack = UIStackView(arrangedSubviews: [title, row])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    /// Creates the profile card containing circle, single-line, and multiline slots.
    ///
    /// - Returns: The styled profile-card container.
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

    /// Creates the label that demonstrates a per-activation appearance override.
    ///
    /// - Returns: The styled override-card container.
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

    // MARK: - Control Configuration

    /// Configures initial control values, actions, menus, and test identifiers.
    private func configureControls() {
        loadingSwitch.isOn = isLoading
        loadingSwitch.accessibilityIdentifier = "example.uikit.loading"
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

    /// Builds a menu that marks the current direction and applies a new selection.
    ///
    /// - Returns: A menu containing all eight shimmer directions.
    private func buildDirectionMenu() -> UIMenu {
        let actions = ShimmerDirection.allCases.map { d in
            UIAction(title: demoDirectionTitle(d), state: d == direction ? .on : .off) { [weak self] _ in
                self?.direction = d
                self?.directionButton.menu = self?.buildDirectionMenu()   // Refresh the selected checkmark.
                self?.updateDirectionTitle()
                self?.applyConfig()
            }
        }
        return UIMenu(children: actions)
    }

    /// Updates the direction button with the current localized direction title.
    private func updateDirectionTitle() {
        directionButton.setTitle(demoDirectionTitle(direction) + " ▾", for: .normal)
    }

    /// Assigns representative content before skeleton activation captures label layout.
    private func seedContentText() {
        let p = DemoProfile.samples[2]
        nameLabel.text = p.name
        priceLabel.text = p.price
        bioLabel.text = p.bio
        overrideLabel.text = "这段始终用固定暖色 + 左上→右下 扫光，与上面面板互不影响。"
    }

    // MARK: - Applying Configuration

    /// Updates global appearance and rebuilds every controlled slot by snapshot contract.
    private func applyConfig() {
        Skeleton.appearance = config
        shapeBoxWidth.constant = (demoShape == .circle) ? 64 : 200

        // Global slots deactivate first so reactivation snapshots the new configuration.
        rebuild(shapeBox, shape: demoShape.skeletonShape)
        rebuild(avatar, shape: .circle)
        rebuild(nameLabel)
        rebuild(priceLabel)
        rebuild(bioLabel)
        rebuildLogo()
        // The per-call override remains independent of panel changes.
        rebuild(overrideLabel, appearance: overrideConfig)
    }

    /// Rebuilds the bitmap-masked logo for the current loading state.
    private func rebuildLogo() {
        logoView.skeleton(false, mask: .ownImage)
        if isLoading { logoView.skeleton(true, mask: .ownImage) }
    }

    /// Deactivates and conditionally reactivates one geometric skeleton slot.
    ///
    /// - Parameters:
    ///   - v: The view whose activation snapshot must be refreshed.
    ///   - shape: The geometric placeholder shape. The default uses configuration radius.
    ///   - appearance: An optional per-activation appearance override.
    private func rebuild(_ v: UIView,
                         shape: SkeletonShape = .roundedRect(cornerRadius: nil),
                         appearance: SkeletonConfiguration? = nil) {
        v.skeleton(false)
        if isLoading { v.skeleton(true, shape: shape, appearance: appearance) }
    }

    // MARK: - Callbacks

    /// Applies a changed loading-switch value to every controlled slot.
    @objc private func loadingChanged()  { isLoading = loadingSwitch.isOn; applyConfig() }
    /// Applies the selected shape to the geometric example.
    @objc private func shapeChanged()    { demoShape = DemoShape.allCases[shapeSeg.selectedSegmentIndex]; applyConfig() }
    /// Applies the selected color preset globally.
    @objc private func themeChanged()    { theme = DemoColorTheme.allCases[themeSeg.selectedSegmentIndex]; applyConfig() }
    /// Applies the selected sweep duration globally.
    @objc private func durationChanged() { duration = Double(durationSlider.value); applyConfig() }
    /// Applies the selected normalized highlight-band width globally.
    @objc private func bandWidthChanged(){ bandWidth = Double(bandWidthSlider.value); applyConfig() }

    // MARK: - View Helpers

    /// Creates a multiline section heading label.
    ///
    /// - Parameter text: The localized heading text.
    /// - Returns: A configured headline label.
    private func sectionTitle(_ text: String) -> UILabel {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .headline)
        l.text = text
        l.numberOfLines = 0
        return l
    }

    /// Creates a labeled horizontal control row.
    ///
    /// - Parameters:
    ///   - title: The localized field title.
    ///   - control: The UIKit control placed after the label.
    /// - Returns: A horizontally aligned stack view.
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

    /// Wraps content in the Example's standard rounded card container.
    ///
    /// - Parameter content: The content view pinned with 12-point insets.
    /// - Returns: The styled container view.
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
