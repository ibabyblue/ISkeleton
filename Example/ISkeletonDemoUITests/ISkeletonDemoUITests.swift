import XCTest

/// Verifies that the Example exposes both supported framework integrations.
@MainActor
final class ISkeletonDemoUITests: XCTestCase {
    /// Stops immediately after the first failed assertion.
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Opens the SwiftUI and UIKit labs and verifies their loading controls.
    func testCatalogExposesSwiftUIAndUIKitLabs() {
        let app = XCUIApplication()
        app.launch()

        let swiftUITab = app.tabBars.buttons["SwiftUI"]
        let uiKitTab = app.tabBars.buttons["UIKit"]
        XCTAssertTrue(swiftUITab.waitForExistence(timeout: 2))
        XCTAssertTrue(uiKitTab.waitForExistence(timeout: 2))
        XCTAssertTrue(
            app.switches["example.swiftui.loading"]
                .waitForExistence(timeout: 2)
        )

        uiKitTab.tap()

        XCTAssertTrue(
            app.switches["example.uikit.loading"]
                .waitForExistence(timeout: 2)
        )
    }
}
