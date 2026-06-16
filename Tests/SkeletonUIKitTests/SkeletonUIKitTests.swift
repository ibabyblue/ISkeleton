#if canImport(UIKit)
import XCTest
import UIKit
@testable import SkeletonUIKit

final class SkeletonUIKitPackageTests: XCTestCase {
    func test_packageBuilds() {
        XCTAssertTrue(true)
    }
}

final class SkeletonLineLayoutTests: XCTestCase {

    private func attr(_ s: String, _ size: CGFloat = 17) -> NSAttributedString {
        NSAttributedString(string: s, attributes: [.font: UIFont.systemFont(ofSize: size)])
    }

    func test_singleShortLine_oneFragment_widthLessThanContainer() {
        let lines = SkeletonLineLayout.lineRects(
            for: attr("Hi"), width: 300, numberOfLines: 0,
            lineBreakMode: .byWordWrapping)
        XCTAssertEqual(lines.count, 1)
        XCTAssertLessThan(lines[0].width, 300)
        XCTAssertGreaterThan(lines[0].width, 0)
    }

    func test_longText_wrapsToMultipleLines() {
        let long = String(repeating: "word ", count: 60)
        let lines = SkeletonLineLayout.lineRects(
            for: attr(long), width: 200, numberOfLines: 0,
            lineBreakMode: .byWordWrapping)
        XCTAssertGreaterThan(lines.count, 2)
    }

    func test_numberOfLinesLimitIsRespected() {
        let long = String(repeating: "word ", count: 60)
        let lines = SkeletonLineLayout.lineRects(
            for: attr(long), width: 200, numberOfLines: 2,
            lineBreakMode: .byTruncatingTail)
        XCTAssertLessThanOrEqual(lines.count, 2)
    }

    func test_emptyText_returnsNoLines() {
        let lines = SkeletonLineLayout.lineRects(
            for: attr(""), width: 200, numberOfLines: 0,
            lineBreakMode: .byWordWrapping)
        XCTAssertTrue(lines.isEmpty)
    }

    func test_rgbaToUIColor_roundTripsComponents() {
        let ui = SkeletonRGBA(r: 0.2, g: 0.4, b: 0.6, a: 0.8).uiColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        XCTAssertEqual(Double(r), 0.2, accuracy: 1e-3)
        XCTAssertEqual(Double(g), 0.4, accuracy: 1e-3)
        XCTAssertEqual(Double(b), 0.6, accuracy: 1e-3)
        XCTAssertEqual(Double(a), 0.8, accuracy: 1e-3)
    }
}

final class UIViewSkeletonTests: XCTestCase {

    @MainActor
    private func overlayCount(_ v: UIView) -> Int {
        v.subviews.filter { $0 is SkeletonOverlayView }.count
    }

    @MainActor
    func test_skeletonTrue_addsOneOverlay() {
        let label = UILabel()
        label.text = "￥00.00"
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        label.skeleton(true)
        XCTAssertEqual(overlayCount(label), 1)
    }

    @MainActor
    func test_skeletonTrueTwice_isIdempotent() {
        let label = UILabel()
        label.text = "￥00.00"
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        label.skeleton(true)
        label.skeleton(true)
        XCTAssertEqual(overlayCount(label), 1)
    }

    @MainActor
    func test_skeletonFalse_removesOverlay() {
        let label = UILabel()
        label.text = "￥00.00"
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        label.skeleton(true)
        label.skeleton(false)
        XCTAssertEqual(overlayCount(label), 0)
    }

    @MainActor
    func test_skeletonFalseWithoutActive_noCrash() {
        let v = UIView()
        v.skeleton(false)
        XCTAssertEqual(overlayCount(v), 0)
    }

    @MainActor
    func test_overlayDoesNotAffectIntrinsicSize() {
        let label = UILabel()
        label.text = "￥00.00"
        let before = label.intrinsicContentSize
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        label.skeleton(true)
        XCTAssertEqual(label.intrinsicContentSize, before)
    }
}

final class SkeletonOverlayBehaviorTests: XCTestCase {

    @MainActor
    private func firstOverlay(_ v: UIView) -> SkeletonOverlayView? {
        v.subviews.compactMap { $0 as? SkeletonOverlayView }.first
    }

    @MainActor
    func test_skeletonAfterExternalRemoval_reattachesWithoutCrash() {
        let label = UILabel()
        label.text = "￥00.00"
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 20)
        label.skeleton(true)
        // 模拟视图复用：外部直接移除 overlay
        label.subviews.compactMap { $0 as? SkeletonOverlayView }.forEach { $0.removeFromSuperview() }
        // 再次激活：不崩溃，且重新挂上恰好一个 overlay
        label.skeleton(true)
        XCTAssertEqual(label.subviews.filter { $0 is SkeletonOverlayView }.count, 1)
    }

    @MainActor
    func test_singleLineLabel_buildsOneBar() {
        let label = UILabel()
        label.text = "Hi"
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 24)
        label.skeleton(true)
        let overlay = firstOverlay(label)
        overlay?.layoutIfNeeded()
        XCTAssertEqual(overlay?.builtBarCountForTesting, 1)
    }

    @MainActor
    func test_multiLineLabel_buildsMultipleBars() {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = String(repeating: "word ", count: 60)
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        label.skeleton(true)
        let overlay = firstOverlay(label)
        overlay?.layoutIfNeeded()
        XCTAssertGreaterThan(overlay?.builtBarCountForTesting ?? 0, 1)
    }

    @MainActor
    func test_shimmerClock_registersWhileActiveAndUnregistersWhenInactive() {
        let label = UILabel()
        label.text = "x"
        label.frame = CGRect(x: 0, y: 0, width: 80, height: 20)
        let before = ShimmerClock.shared.drivenCountForTesting
        label.skeleton(true)
        XCTAssertEqual(ShimmerClock.shared.drivenCountForTesting, before + 1)
        label.skeleton(false)
        XCTAssertEqual(ShimmerClock.shared.drivenCountForTesting, before)
    }
}
#endif
