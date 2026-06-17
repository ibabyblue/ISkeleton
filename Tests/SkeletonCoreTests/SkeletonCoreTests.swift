import XCTest
@testable import SkeletonCore

final class SkeletonCorePackageTests: XCTestCase {
    func test_packageBuilds() {
        XCTAssertTrue(true)
    }
}

final class SkeletonRGBATests: XCTestCase {
    func test_init_defaultAlphaIsOne() {
        let c = SkeletonRGBA(r: 0.1, g: 0.2, b: 0.3)
        XCTAssertEqual(c.a, 1, accuracy: 1e-9)
    }

    func test_init_storesComponents() {
        let c = SkeletonRGBA(r: 0.1, g: 0.2, b: 0.3, a: 0.4)
        XCTAssertEqual(c.r, 0.1, accuracy: 1e-9)
        XCTAssertEqual(c.g, 0.2, accuracy: 1e-9)
        XCTAssertEqual(c.b, 0.3, accuracy: 1e-9)
        XCTAssertEqual(c.a, 0.4, accuracy: 1e-9)
    }
}

final class SkeletonConfigurationTests: XCTestCase {
    func test_defaults() {
        let c = SkeletonConfiguration.default
        XCTAssertEqual(c.duration, 1.4, accuracy: 1e-9)
        XCTAssertEqual(c.bandWidth, 0.6, accuracy: 1e-9)
        XCTAssertEqual(c.cornerRadius, 5, accuracy: 1e-9)
        XCTAssertEqual(c.baseColor.a, 0.8, accuracy: 1e-9)
    }

    func test_isMutableValueType() {
        var c = SkeletonConfiguration.default
        c.duration = 2
        c.cornerRadius = 8
        XCTAssertEqual(c.duration, 2, accuracy: 1e-9)
        XCTAssertEqual(c.cornerRadius, 8, accuracy: 1e-9)
    }

    func test_defaultDirection_isLeftToRight() {
        XCTAssertEqual(SkeletonConfiguration.default.direction, .leftToRight)
    }
}

final class ShimmerPhaseTests: XCTestCase {
    func test_atZero_isNegativeBandWidth() {
        let p = ShimmerPhase.phase(at: 0, duration: 1.4, bandWidth: 0.6)
        XCTAssertEqual(p, -0.6, accuracy: 1e-9)
    }

    func test_nearEnd_approachesOne() {
        let p = ShimmerPhase.phase(at: 1.4 - 1e-6, duration: 1.4, bandWidth: 0.6)
        XCTAssertEqual(p, 1.0, accuracy: 1e-3)
    }

    func test_monotonicWithinCycle() {
        let a = ShimmerPhase.phase(at: 0.3, duration: 1.4, bandWidth: 0.6)
        let b = ShimmerPhase.phase(at: 0.9, duration: 1.4, bandWidth: 0.6)
        XCTAssertGreaterThan(b, a)
    }

    func test_loopsByDuration() {
        let p0 = ShimmerPhase.phase(at: 0.25, duration: 1.4, bandWidth: 0.6)
        let p1 = ShimmerPhase.phase(at: 0.25 + 1.4, duration: 1.4, bandWidth: 0.6)
        XCTAssertEqual(p0, p1, accuracy: 1e-9)
    }

    func test_rangeStaysWithinOffscreenBounds() {
        for i in 0..<100 {
            let t = Double(i) / 100 * 1.4
            let p = ShimmerPhase.phase(at: t, duration: 1.4, bandWidth: 0.6)
            XCTAssertGreaterThanOrEqual(p, -0.6 - 1e-9)
            XCTAssertLessThanOrEqual(p, 1.0 + 1e-9)
        }
    }
}

final class SkeletonShapeTests: XCTestCase {
    private let size = CGSize(width: 200, height: 20)

    func test_roundedRect_nil_usesDefault() {
        XCTAssertEqual(SkeletonShape.roundedRect(cornerRadius: nil).cornerRadius(for: size, default: 5), 5, accuracy: 1e-9)
    }
    func test_roundedRect_explicit_usesGiven() {
        XCTAssertEqual(SkeletonShape.roundedRect(cornerRadius: 8).cornerRadius(for: size, default: 5), 8, accuracy: 1e-9)
    }
    func test_circle_isHalfMinDimension() {
        XCTAssertEqual(SkeletonShape.circle.cornerRadius(for: CGSize(width: 80, height: 80), default: 5), 40, accuracy: 1e-9)
        XCTAssertEqual(SkeletonShape.circle.cornerRadius(for: size, default: 5), 10, accuracy: 1e-9)
    }
    func test_capsule_isHalfMinDimension() {
        XCTAssertEqual(SkeletonShape.capsule.cornerRadius(for: size, default: 5), 10, accuracy: 1e-9)
    }
}

final class SkeletonLineMetricsTests: XCTestCase {
    func test_lineCount_roundsToNearest() {
        XCTAssertEqual(SkeletonLineMetrics.lineCount(height: 60, lineHeight: 20), 3)
        XCTAssertEqual(SkeletonLineMetrics.lineCount(height: 69, lineHeight: 20), 3)   // 3.45 → 3
        XCTAssertEqual(SkeletonLineMetrics.lineCount(height: 71, lineHeight: 20), 4)   // 3.55 → 4
    }
    func test_lineCount_atLeastOne() {
        XCTAssertEqual(SkeletonLineMetrics.lineCount(height: 5, lineHeight: 20), 1)
        XCTAssertEqual(SkeletonLineMetrics.lineCount(height: 0, lineHeight: 20), 1)
    }
    func test_lineCount_invalidLineHeight_isOne() {
        XCTAssertEqual(SkeletonLineMetrics.lineCount(height: 100, lineHeight: 0), 1)
        XCTAssertEqual(SkeletonLineMetrics.lineCount(height: 100, lineHeight: -5), 1)
    }
    func test_barHeight_defaultRatio() {
        XCTAssertEqual(SkeletonLineMetrics.barHeight(lineHeight: 20), 14, accuracy: 1e-9)
    }
    func test_barHeight_neverNegative() {
        XCTAssertEqual(SkeletonLineMetrics.barHeight(lineHeight: -10), 0, accuracy: 1e-9)
    }
}

final class ShimmerDirectionTests: XCTestCase {
    func test_leftToRight_reducesToCurrentHorizontal() {
        let pts = ShimmerDirection.leftToRight.gradientPoints(phase: 0.3, bandWidth: 0.6)
        XCTAssertEqual(pts.start.x, 0.3, accuracy: 1e-9)
        XCTAssertEqual(pts.start.y, 0.5, accuracy: 1e-9)
        XCTAssertEqual(pts.end.x, 0.9, accuracy: 1e-9)
        XCTAssertEqual(pts.end.y, 0.5, accuracy: 1e-9)
    }

    func test_topRightToBottomLeft_endpoints() {
        XCTAssertEqual(ShimmerDirection.topRightToBottomLeft.start, CGPoint(x: 1, y: 0))
        XCTAssertEqual(ShimmerDirection.topRightToBottomLeft.end, CGPoint(x: 0, y: 1))
    }

    func test_topRightToBottomLeft_gradientPointsAtPhaseZero() {
        let pts = ShimmerDirection.topRightToBottomLeft.gradientPoints(phase: 0, bandWidth: 0.6)
        XCTAssertEqual(pts.start.x, 1, accuracy: 1e-9)
        XCTAssertEqual(pts.start.y, 0, accuracy: 1e-9)
        XCTAssertEqual(pts.end.x, 0.4, accuracy: 1e-9)
        XCTAssertEqual(pts.end.y, 0.6, accuracy: 1e-9)
    }

    func test_allCases_startAndEndWithinUnitSquare() {
        for d in ShimmerDirection.allCases {
            for p in [d.start, d.end] {
                XCTAssertTrue((0...1).contains(p.x) && (0...1).contains(p.y), "\(d)")
            }
        }
    }
}
