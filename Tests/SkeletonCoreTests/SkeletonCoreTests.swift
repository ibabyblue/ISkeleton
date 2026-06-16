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
