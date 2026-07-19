import SwiftUI
import SkeletonUIKit   // Also verifies that the Skeleton-UIKit product links successfully.

/// Launches the two-tab SwiftUI and UIKit integration Example.
@main
struct ISkeletonDemoApp: App {
    /// Configures the UIKit product's process-wide default appearance at launch.
    init() {
        // Set the global appearance while exercising the linked UIKit module.
        Skeleton.appearance = .default
    }

    /// The scene containing both supported framework labs.
    var body: some Scene {
        WindowGroup {
            TabView {
                SwiftUIDemoView()
                    .tabItem { Label("SwiftUI", systemImage: "swift") }
                UIKitDemoScreen()
                    .ignoresSafeArea()
                    .tabItem { Label("UIKit", systemImage: "rectangle.on.rectangle") }
            }
        }
    }
}
