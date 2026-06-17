import XCTest
import SwiftUI
@testable import SkeletonSwiftUI

final class TextStyleMetricsTests: XCTestCase {
    /// 覆盖 iOS 15 / macOS 12 全部公开 Font.TextStyle，确保映射无遗漏且行高有效。
    private let styles: [Font.TextStyle] = [
        .largeTitle, .title, .title2, .title3, .headline, .subheadline,
        .body, .callout, .footnote, .caption, .caption2
    ]

    func test_allStyles_havePositiveLineHeight() {
        for s in styles {
            XCTAssertGreaterThan(TextStyleMetrics.lineHeight(for: s), 0, "\(s) 行高应 > 0")
        }
    }

    func test_largerStyle_hasTallerLine() {
        XCTAssertGreaterThan(
            TextStyleMetrics.lineHeight(for: .largeTitle),
            TextStyleMetrics.lineHeight(for: .footnote)
        )
    }
}
