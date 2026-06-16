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

/// UIKit 演示：每个控件用 `view.skeleton(true/false)`；bio label `numberOfLines = 0` 展示逐行条。
final class UIKitDemoViewController: UIViewController {
    private let stack = UIStackView()
    private var cards: [CardView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIKit"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reload", style: .plain, target: self, action: #selector(reload))

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -16),
        ])

        for _ in 0..<3 {
            let card = CardView()
            stack.addArrangedSubview(card)
            cards.append(card)
        }
        reload()
    }

    @objc private func reload() {
        for card in cards { card.configure(profile: nil) }   // 占位文案 + 骨架
        Task {
            let profiles = await DemoLoader.load()
            for (i, card) in cards.enumerated() {
                card.configure(profile: profiles[i % profiles.count])
            }
        }
    }
}

/// 单张卡片：头像占位 + 昵称/价格/多行简介。
final class CardView: UIView {
    private let avatar = UIView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let bioLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12

        avatar.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        avatar.layer.cornerRadius = 28
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
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 56),
            avatar.heightAnchor.constraint(equalToConstant: 56),
            row.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// profile 非空 → 真实内容（先关骨架再设真实文案）；nil → 设代表性占位文案后开骨架。
    func configure(profile: DemoProfile?) {
        if let p = profile {
            avatar.skeleton(false)
            nameLabel.skeleton(false);  nameLabel.text = p.name
            priceLabel.skeleton(false); priceLabel.text = p.price
            bioLabel.skeleton(false);   bioLabel.text = p.bio
        } else {
            nameLabel.text = DemoProfile.placeholderName
            priceLabel.text = DemoProfile.placeholderPrice
            bioLabel.text = DemoProfile.placeholderBio
            avatar.skeleton(true)
            nameLabel.skeleton(true)
            priceLabel.skeleton(true)
            bioLabel.skeleton(true)
        }
    }
}
