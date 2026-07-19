#if canImport(UIKit)
import UIKit

/// Uses TextKit to calculate the content-driven line fragments of a UIKit label.
enum SkeletonLineLayout {
    /// Lays out attributed text and returns the used rectangle for each visible line.
    ///
    /// Truncating modes normalize to word wrapping for unlimited-line labels because
    /// applying a truncating mode directly would collapse TextKit output to one line.
    ///
    /// - Parameters:
    ///   - attributedText: The text and font attributes to lay out.
    ///   - width: The available label width, in points.
    ///   - numberOfLines: The label line limit. `0` means unlimited lines.
    ///   - lineBreakMode: The label's requested wrapping or truncation behavior.
    /// - Returns: Used line rectangles in layout order, or an empty array for empty text or nonpositive width.
    static func lineRects(for attributedText: NSAttributedString,
                          width: CGFloat,
                          numberOfLines: Int,
                          lineBreakMode: NSLineBreakMode) -> [CGRect] {
        guard attributedText.length > 0, width > 0 else { return [] }

        // Match UILabel: zero lines means unlimited word wrapping. Truncating modes
        // affect only a limited final line; passing one directly would collapse TextKit
        // output to one line, so unlimited labels normalize to word wrapping.
        let effectiveBreakMode: NSLineBreakMode
        switch lineBreakMode {
        case .byTruncatingHead, .byTruncatingMiddle, .byTruncatingTail:
            effectiveBreakMode = numberOfLines == 0 ? .byWordWrapping : lineBreakMode
        default:
            effectiveBreakMode = lineBreakMode
        }

        // UILabel-generated attributed text embeds a paragraph line-break mode that
        // overrides its text container. Normalize that paragraph style so multiline
        // wrapping follows the container configuration.
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
