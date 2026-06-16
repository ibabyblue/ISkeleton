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
