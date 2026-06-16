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

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let container = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
        container.lineFragmentPadding = 0
        container.maximumNumberOfLines = max(0, numberOfLines)
        container.lineBreakMode = lineBreakMode
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
