import SwiftUI
import SkeletonUIKit   // 同时验证 Skeleton-UIKit product 链接成功

@main
struct ISkeletonDemoApp: App {
    init() {
        // 设置全局骨架外观（顺带验证 SkeletonUIKit 链接）。
        Skeleton.appearance = .default
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                Text("SwiftUI demo (placeholder)")
                    .tabItem { Label("SwiftUI", systemImage: "swift") }
                Text("UIKit demo (placeholder)")
                    .tabItem { Label("UIKit", systemImage: "rectangle.on.rectangle") }
            }
        }
    }
}
