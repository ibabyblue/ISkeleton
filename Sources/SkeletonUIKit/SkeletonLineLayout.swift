#if canImport(UIKit)
import UIKit

/// 用 TextKit 把一段富文本按给定宽度排版，返回每行的 used rect（供逐行占位条使用）。
/// 行数/末行宽度完全由文案决定 —— 不写死任何布局约束。
enum SkeletonLineLayout {
    static func lineRects(for attributedText: NSAttributedString,
                          width: CGFloat,
                          numberOfLines: Int,
                          lineBreakMode: NSLineBreakMode) -> [CGRect] {
        guard attributedText.length > 0, width > 0 else { return [] }

        // 复刻 UILabel：numberOfLines == 0 表示无限行 → 整体按 word wrapping 折行；
        // 截断类的 lineBreakMode（.byTruncatingHead/Middle/Tail）只在有行数上限时对末行生效，
        // 直接喂给 TextKit 会把文本压成单行，故此处归一到 .byWordWrapping。
        let effectiveBreakMode: NSLineBreakMode
        switch lineBreakMode {
        case .byTruncatingHead, .byTruncatingMiddle, .byTruncatingTail:
            effectiveBreakMode = numberOfLines == 0 ? .byWordWrapping : lineBreakMode
        default:
            effectiveBreakMode = lineBreakMode
        }

        // UILabel 合成的 attributedText 会带上 paragraphStyle，其内嵌的 lineBreakMode（默认 .byTruncatingTail）
        // 优先级高于 container.lineBreakMode，会把多行文本压成单行。这里覆写段落样式的折行模式以使容器折行生效。
        let normalized = NSMutableAttributedString(attributedString: attributedText)
        let fullRange = NSRange(location: 0, length: normalized.length)
        normalized.enumerateAttribute(.paragraphStyle, in: fullRange, options: []) { value, range, _ in
            let style = (value as? NSParagraphStyle).flatMap {
                $0.mutableCopy() as? NSMutableParagraphStyle
            } ?? NSMutableParagraphStyle()
            style.lineBreakMode = effectiveBreakMode
            normalized.addAttribute(.paragraphStyle, value: style, range: range)
        }

        let textStorage = NSTextStorage(attributedString: normalized)
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
        container.lineFragmentPadding = 0
        container.maximumNumberOfLines = max(0, numberOfLines)
        container.lineBreakMode = effectiveBreakMode
        layoutManager.addTextContainer(container)
        textStorage.addLayoutManager(layoutManager)

        layoutManager.ensureLayout(for: container)

        var rects: [CGRect] = []
        let glyphRange = layoutManager.glyphRange(for: container)
        layoutManager.enumerateLineFragments(forGlyphRange: glyphRange) { _, usedRect, _, _, _ in
            rects.append(usedRect)
        }
        return rects
    }
}
#endif
