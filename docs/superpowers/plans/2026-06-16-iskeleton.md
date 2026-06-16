# ISkeleton Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `ISkeleton` SPM package — a slot-level shimmer skeleton with a pure `SkeletonCore`, a SwiftUI modifier, and a UIKit `UIView` extension whose size is driven by the host content (multi-line labels get per-line bars), all sharing one global shimmer phase.

**Architecture:** Three modules — `SkeletonCore` (platform-neutral phase math + config + RGBA), `SkeletonSwiftUI` (`.skeleton(_:)` modifier via `.hidden()` + shimmer overlay, driven by `TimelineView(.animation)`), `SkeletonUIKit` (`UIView.skeleton(_:)` adds a `SkeletonOverlayView`; labels are measured with TextKit for per-line bars; one shared `CADisplayLink` `ShimmerClock` drives all overlays). Both UI modules compute phase from `Date().timeIntervalSinceReferenceDate` through Core, so every skeleton is in phase.

**Tech Stack:** Swift 5.10, SwiftPM, iOS 15+, SwiftUI, UIKit, TextKit (`NSLayoutManager`), `CADisplayLink`, XCTest.

> **提交说明（项目规则）:** 禁止未授权的 `git commit`。各任务末尾的 commit 步骤需用户显式授权后执行；提交信息仅单行标题、不加 `Co-Authored-By`。

> **测试运行说明:**
> - `SkeletonCore` 测试只依赖 Foundation/CoreGraphics → `swift test --filter SkeletonCoreTests` 在 macOS 跑。
> - `SkeletonUIKit` 测试在 `#if canImport(UIKit)` 下，仅 iOS 模拟器跑：
>   `xcodebuild test -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16'`
>   （scheme 名以 `xcodebuild -list` 实际输出为准；SwiftPM 包通常生成 `<Package>-Package` 聚合 scheme。）
> - SwiftUI 模块只做编译校验（iOS 构建）+ Core 相位复用测试，无视图快照。

---

## 文件结构

```
ISkeleton/
├─ Package.swift
├─ Sources/
│  ├─ SkeletonCore/
│  │  ├─ SkeletonRGBA.swift          // RGBA 值类型
│  │  ├─ SkeletonConfiguration.swift // 外观配置 + 默认值
│  │  └─ ShimmerPhase.swift          // 纯相位函数
│  ├─ SkeletonSwiftUI/
│  │  ├─ Exports.swift               // @_exported import SkeletonCore
│  │  ├─ SkeletonRGBA+Color.swift    // RGBA → Color
│  │  ├─ SkeletonAppearance.swift    // Environment 注入
│  │  └─ SkeletonModifier.swift      // .skeleton(_:) + ShimmerPlaceholder
│  └─ SkeletonUIKit/
│     ├─ Exports.swift               // @_exported import SkeletonCore
│     ├─ SkeletonRGBA+UIColor.swift  // RGBA → UIColor
│     ├─ Skeleton.swift              // 全局 appearance + UIView.skeleton(_:)
│     ├─ SkeletonLineLayout.swift    // TextKit 行片段测量（可单测）
│     ├─ SkeletonOverlayView.swift   // 占位条 overlay
│     └─ ShimmerClock.swift          // 共享 CADisplayLink 驱动
└─ Tests/
   ├─ SkeletonCoreTests/SkeletonCoreTests.swift
   └─ SkeletonUIKitTests/SkeletonUIKitTests.swift
```

---

## Task 1: 包脚手架

**Files:**
- Create: `Package.swift`
- Create: `Sources/SkeletonCore/SkeletonCore.swift`（占位，确保 target 可编译）
- Create: `Sources/SkeletonSwiftUI/Exports.swift`
- Create: `Sources/SkeletonUIKit/Exports.swift`
- Create: `Tests/SkeletonCoreTests/SkeletonCoreTests.swift`（占位）

- [ ] **Step 1: 写 Package.swift**

```swift
// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "ISkeleton",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Skeleton-Core", targets: ["SkeletonCore"]),
        .library(name: "Skeleton-SwiftUI", targets: ["SkeletonSwiftUI"]),
        .library(name: "Skeleton-UIKit", targets: ["SkeletonUIKit"]),
    ],
    targets: [
        .target(name: "SkeletonCore"),
        .target(name: "SkeletonSwiftUI", dependencies: ["SkeletonCore"]),
        .target(name: "SkeletonUIKit", dependencies: ["SkeletonCore"]),
        .testTarget(name: "SkeletonCoreTests", dependencies: ["SkeletonCore"]),
        .testTarget(name: "SkeletonUIKitTests", dependencies: ["SkeletonUIKit"]),
    ]
)
```

- [ ] **Step 2: 写各 target 的占位/导出文件**

`Sources/SkeletonCore/SkeletonCore.swift`:
```swift
//  SkeletonCore — 平台无关的骨架逻辑（相位、配置、颜色值类型）。
```

`Sources/SkeletonSwiftUI/Exports.swift`:
```swift
@_exported import SkeletonCore
```

`Sources/SkeletonUIKit/Exports.swift`:
```swift
@_exported import SkeletonCore
```

`Tests/SkeletonCoreTests/SkeletonCoreTests.swift`:
```swift
import XCTest
@testable import SkeletonCore

final class SkeletonCorePackageTests: XCTestCase {
    func test_packageBuilds() {
        XCTAssertTrue(true)
    }
}
```

`Tests/SkeletonUIKitTests/SkeletonUIKitTests.swift`（占位，后续 Task 在 `#if` 块内追加用例；
没有源文件的 testTarget 会让 SwiftPM 报错，故此处先建壳）:
```swift
#if canImport(UIKit)
import XCTest
@testable import SkeletonUIKit

final class SkeletonUIKitPackageTests: XCTestCase {
    func test_packageBuilds() {
        XCTAssertTrue(true)
    }
}
#endif
```

- [ ] **Step 3: 构建并初始化 git**

Run:
```bash
cd /Users/zhangbiao/work/other/ios_modules/ISkeleton
git init -q
swift build
```
Expected: `Build complete!`（macOS 上 UIKit/SwiftUI target 经 `canImport` 不会因缺符号失败；本步仅文件壳）。

- [ ] **Step 4: 跑占位测试**

Run: `swift test --filter SkeletonCorePackageTests`
Expected: PASS。

- [ ] **Step 5: 提交（需授权）**

```bash
git add -A
git commit -m "chore: scaffold ISkeleton package with three targets"
```

---

## Task 2: SkeletonRGBA + SkeletonConfiguration

**Files:**
- Create: `Sources/SkeletonCore/SkeletonRGBA.swift`
- Create: `Sources/SkeletonCore/SkeletonConfiguration.swift`
- Test: `Tests/SkeletonCoreTests/SkeletonCoreTests.swift`

- [ ] **Step 1: 写失败测试**

在 `SkeletonCoreTests.swift` 顶部 `import` 后追加：

```swift
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
        XCTAssertEqual(c.baseColor.a, 1, accuracy: 1e-9)
    }

    func test_isMutableValueType() {
        var c = SkeletonConfiguration.default
        c.duration = 2
        c.cornerRadius = 8
        XCTAssertEqual(c.duration, 2, accuracy: 1e-9)
        XCTAssertEqual(c.cornerRadius, 8, accuracy: 1e-9)
    }
}
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `swift test --filter SkeletonRGBATests`
Expected: 编译失败，`cannot find 'SkeletonRGBA' in scope`。

- [ ] **Step 3: 实现**

`Sources/SkeletonCore/SkeletonRGBA.swift`:
```swift
import CoreGraphics

/// 平台无关的颜色值（各分量 0...1）。各平台 target 提供到原生颜色的转换。
public struct SkeletonRGBA: Equatable, Sendable {
    public var r: Double
    public var g: Double
    public var b: Double
    public var a: Double

    public init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}
```

`Sources/SkeletonCore/SkeletonConfiguration.swift`:
```swift
import CoreGraphics

/// 骨架外观与扫光参数。所有字段有合理默认值。
public struct SkeletonConfiguration: Equatable, Sendable {
    /// 占位条底色。
    public var baseColor: SkeletonRGBA
    /// 扫光高光色。
    public var highlightColor: SkeletonRGBA
    /// 单次扫光时长（秒）。
    public var duration: TimeInterval
    /// 高光带归一化宽度。
    public var bandWidth: CGFloat
    /// 占位条默认圆角。
    public var cornerRadius: CGFloat

    public init(baseColor: SkeletonRGBA,
                highlightColor: SkeletonRGBA,
                duration: TimeInterval = 1.4,
                bandWidth: CGFloat = 0.6,
                cornerRadius: CGFloat = 5) {
        self.baseColor = baseColor
        self.highlightColor = highlightColor
        self.duration = duration
        self.bandWidth = bandWidth
        self.cornerRadius = cornerRadius
    }

    /// 默认外观：中性灰底 + 偏白高光。
    public static let `default` = SkeletonConfiguration(
        baseColor: SkeletonRGBA(r: 0.91, g: 0.85, b: 0.85, a: 0.8),
        highlightColor: SkeletonRGBA(r: 0.99, g: 0.98, b: 0.98, a: 0.8)
    )
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `swift test --filter SkeletonRGBATests SkeletonConfigurationTests`
Expected: PASS。

- [ ] **Step 5: 提交（需授权）**

```bash
git add Sources/SkeletonCore Tests/SkeletonCoreTests
git commit -m "feat(core): add SkeletonRGBA and SkeletonConfiguration"
```

---

## Task 3: ShimmerPhase

**Files:**
- Create: `Sources/SkeletonCore/ShimmerPhase.swift`
- Test: `Tests/SkeletonCoreTests/SkeletonCoreTests.swift`

- [ ] **Step 1: 写失败测试**

追加到 `SkeletonCoreTests.swift`：

```swift
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
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `swift test --filter ShimmerPhaseTests`
Expected: 编译失败，`cannot find 'ShimmerPhase' in scope`。

- [ ] **Step 3: 实现**

`Sources/SkeletonCore/ShimmerPhase.swift`:
```swift
import CoreGraphics
import Foundation

/// 扫光相位：把绝对时间映射成高光带前缘的归一化位置。
/// band 区间为 [phase, phase + bandWidth]；phase 从 -bandWidth（全在左侧外）线性走到 1（全在右侧外），
/// 按 duration 无缝循环。两平台用同一 `Date().timeIntervalSinceReferenceDate` 代入 → 全局同相位。
public enum ShimmerPhase {
    public static func phase(at time: TimeInterval,
                             duration: TimeInterval,
                             bandWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return -bandWidth }
        let m = time.truncatingRemainder(dividingBy: duration)
        let t = CGFloat((m < 0 ? m + duration : m) / duration)   // 0..<1
        return -bandWidth + t * (1 + bandWidth)
    }
}
```

- [ ] **Step 4: 运行测试，确认通过**

Run: `swift test --filter ShimmerPhaseTests`
Expected: PASS。

- [ ] **Step 5: 提交（需授权）**

```bash
git add Sources/SkeletonCore/ShimmerPhase.swift Tests/SkeletonCoreTests/SkeletonCoreTests.swift
git commit -m "feat(core): add ShimmerPhase time-to-phase mapping"
```

---

## Task 4: SkeletonSwiftUI 模块

**Files:**
- Create: `Sources/SkeletonSwiftUI/SkeletonRGBA+Color.swift`
- Create: `Sources/SkeletonSwiftUI/SkeletonAppearance.swift`
- Create: `Sources/SkeletonSwiftUI/SkeletonModifier.swift`

> 该模块为 SwiftUI/iOS-only，`swift build`（macOS）会经 `canImport(SwiftUI)` 编译；SwiftUI 在 macOS 也可 import，但 `TimelineView`/`UnitPoint` 跨平台可用。仍以 iOS 构建为权威校验。无单测（仅编译 + Core 已覆盖相位）。

- [ ] **Step 1: 实现颜色转换**

`Sources/SkeletonSwiftUI/SkeletonRGBA+Color.swift`:
```swift
import SwiftUI
import SkeletonCore

extension SkeletonRGBA {
    /// 转 SwiftUI Color。
    var color: Color {
        Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
```

- [ ] **Step 2: 实现外观环境注入**

`Sources/SkeletonSwiftUI/SkeletonAppearance.swift`:
```swift
import SwiftUI
import SkeletonCore

private struct SkeletonAppearanceKey: EnvironmentKey {
    static let defaultValue: SkeletonConfiguration = .default
}

public extension EnvironmentValues {
    var skeletonAppearance: SkeletonConfiguration {
        get { self[SkeletonAppearanceKey.self] }
        set { self[SkeletonAppearanceKey.self] = newValue }
    }
}

public extension View {
    /// 注入骨架外观；子树内所有 `.skeleton` 复用之。未注入时用 `SkeletonConfiguration.default`。
    func skeletonAppearance(_ config: SkeletonConfiguration) -> some View {
        environment(\.skeletonAppearance, config)
    }
}
```

- [ ] **Step 3: 实现修饰器**

`Sources/SkeletonSwiftUI/SkeletonModifier.swift`:
```swift
import SwiftUI
import SkeletonCore

public extension View {
    /// active 时：隐藏真实内容但保留其 footprint，叠加圆角扫光占位；false 时原样显示真实内容。
    /// cornerRadius 为 nil 时取外观配置的 cornerRadius。
    func skeleton(_ active: Bool, cornerRadius: CGFloat? = nil) -> some View {
        modifier(SkeletonModifier(active: active, cornerRadius: cornerRadius))
    }
}

private struct SkeletonModifier: ViewModifier {
    let active: Bool
    let cornerRadius: CGFloat?
    @Environment(\.skeletonAppearance) private var config

    func body(content: Content) -> some View {
        if active {
            content
                .hidden()
                .overlay { ShimmerPlaceholder(config: config, cornerRadius: cornerRadius ?? config.cornerRadius) }
        } else {
            content
        }
    }
}

/// 圆角底色 + 同相位移动高光带。
private struct ShimmerPlaceholder: View {
    let config: SkeletonConfiguration
    let cornerRadius: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        TimelineView(.animation) { context in
            let phase = ShimmerPhase.phase(
                at: context.date.timeIntervalSinceReferenceDate,
                duration: config.duration,
                bandWidth: config.bandWidth
            )
            shape
                .fill(config.baseColor.color)
                .overlay {
                    LinearGradient(
                        colors: [.clear, config.highlightColor.color, .clear],
                        startPoint: UnitPoint(x: phase, y: 0.5),
                        endPoint: UnitPoint(x: phase + config.bandWidth, y: 0.5)
                    )
                }
                .clipShape(shape)
        }
    }
}
```

- [ ] **Step 4: iOS 构建校验**

Run（destination id 以本机 `xcrun simctl list devices available | grep iPhone` 为准）:
```bash
xcodebuild build -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "BUILD SUCCEEDED|BUILD FAILED|error:"
```
Expected: `** BUILD SUCCEEDED **`。

- [ ] **Step 5: 提交（需授权）**

```bash
git add Sources/SkeletonSwiftUI
git commit -m "feat(swiftui): add skeleton modifier with synced shimmer"
```

---

## Task 5: UIKit — SkeletonLineLayout（TextKit 行测量，可单测）

**Files:**
- Create: `Sources/SkeletonUIKit/SkeletonRGBA+UIColor.swift`
- Create: `Sources/SkeletonUIKit/SkeletonLineLayout.swift`
- Modify: `Tests/SkeletonUIKitTests/SkeletonUIKitTests.swift`（在 Task 1 建的 `#if canImport(UIKit)` 块内，
  补 `import UIKit` 并追加下面的测试类）

- [ ] **Step 1: 写失败测试**

把 `Tests/SkeletonUIKitTests/SkeletonUIKitTests.swift` 的 `import` 区补上 `import UIKit`，
并在 `#if canImport(UIKit)` 块内追加：

```swift
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
```
（上面两个类追加在既有 `#if canImport(UIKit) ... #endif` 块内部，不要再写新的 `#if`/`#endif`。）

- [ ] **Step 2: 运行测试，确认失败**

Run: `xcodebuild test -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SkeletonUIKitTests/SkeletonLineLayoutTests 2>&1 | grep -E "error:|cannot find"`
Expected: 编译失败，`cannot find 'SkeletonLineLayout'` / `SkeletonRGBA ... uiColor`。

- [ ] **Step 3: 实现颜色转换**

`Sources/SkeletonUIKit/SkeletonRGBA+UIColor.swift`:
```swift
#if canImport(UIKit)
import UIKit
import SkeletonCore

extension SkeletonRGBA {
    /// 转 UIColor。
    var uiColor: UIColor {
        UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
#endif
```

- [ ] **Step 4: 实现行测量**

`Sources/SkeletonUIKit/SkeletonLineLayout.swift`:
```swift
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
```

- [ ] **Step 5: 运行测试，确认通过**

Run: `xcodebuild test -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SkeletonUIKitTests/SkeletonLineLayoutTests 2>&1 | grep -E "Executed|TEST SUCCEEDED|TEST FAILED"`
Expected: 全部 PASS。

- [ ] **Step 6: 提交（需授权）**

```bash
git add Sources/SkeletonUIKit/SkeletonRGBA+UIColor.swift Sources/SkeletonUIKit/SkeletonLineLayout.swift Tests/SkeletonUIKitTests
git commit -m "feat(uikit): add RGBA→UIColor and TextKit line measurement"
```

---

## Task 6: UIKit — ShimmerClock（共享 CADisplayLink）

**Files:**
- Create: `Sources/SkeletonUIKit/ShimmerClock.swift`

> 该类驱动每帧扫光，时序依赖 `CADisplayLink`，不做精确时序单测；其增删/停表在 Task 8 的 overlay 集成里通过行为间接覆盖。本任务只确保编译。`SkeletonOverlayView` 在 Task 7 定义；为可独立编译，先以一个最小协议解耦。

- [ ] **Step 1: 实现**

`Sources/SkeletonUIKit/ShimmerClock.swift`:
```swift
#if canImport(UIKit)
import UIKit
import SkeletonCore

/// 被 ShimmerClock 每帧驱动的对象。
@MainActor
protocol ShimmerDriven: AnyObject {
    /// 应用本帧扫光相位（high-light band 前缘的归一化位置）。
    func applyShimmerPhase(_ phase: CGFloat)
    /// 当前生效的外观（用于读取 duration/bandWidth）。
    var shimmerConfiguration: SkeletonConfiguration { get }
}

/// CADisplayLink 弱引用代理，避免 link 强引用 clock。
private final class ClockProxy: NSObject {
    weak var clock: ShimmerClock?
    @MainActor @objc func tick(_ link: CADisplayLink) {
        if let clock { clock.onFrame() } else { link.invalidate() }
    }
}

/// 进程内共享的扫光时钟：一条 CADisplayLink 以同一相位驱动所有激活的 overlay ⇒ 全局同相位。
@MainActor
final class ShimmerClock {
    static let shared = ShimmerClock()

    private let driven = NSHashTable<AnyObject>.weakObjects()
    private var displayLink: CADisplayLink?

    private init() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleForeground),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    func register(_ object: ShimmerDriven) {
        driven.add(object)
        startIfNeeded()
    }

    func unregister(_ object: ShimmerDriven) {
        driven.remove(object)
        stopIfIdle()
    }

    private func startIfNeeded() {
        guard displayLink == nil, driven.anyObject != nil else { return }
        let proxy = ClockProxy()
        proxy.clock = self
        let link = CADisplayLink(target: proxy, selector: #selector(ClockProxy.tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopIfIdle() {
        guard driven.allObjects.isEmpty else { return }
        displayLink?.invalidate()
        displayLink = nil
    }

    fileprivate func onFrame() {
        let now = Date().timeIntervalSinceReferenceDate
        let objects = driven.allObjects.compactMap { $0 as? ShimmerDriven }
        if objects.isEmpty { stopIfIdle(); return }
        for o in objects {
            let cfg = o.shimmerConfiguration
            let phase = ShimmerPhase.phase(at: now, duration: cfg.duration, bandWidth: cfg.bandWidth)
            o.applyShimmerPhase(phase)
        }
    }

    @objc private func handleForeground() {
        // 回前台时 link 可能被系统暂停；重启以恢复。
        displayLink?.invalidate()
        displayLink = nil
        startIfNeeded()
    }
}
#endif
```

- [ ] **Step 2: 构建校验**

Run: `xcodebuild build -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "BUILD SUCCEEDED|BUILD FAILED|error:"`
Expected: `** BUILD SUCCEEDED **`。

- [ ] **Step 3: 提交（需授权）**

```bash
git add Sources/SkeletonUIKit/ShimmerClock.swift
git commit -m "feat(uikit): add shared CADisplayLink ShimmerClock"
```

---

## Task 7: UIKit — SkeletonOverlayView

**Files:**
- Create: `Sources/SkeletonUIKit/SkeletonOverlayView.swift`

> overlay 持有占位条与扫光，实现 `ShimmerDriven`。占位条形态：UILabel 逐行（用 Task 5 的 `SkeletonLineLayout`），其它单条覆盖 bounds。无单测（行为在 Task 8 集成测试覆盖）；本任务只确保编译。

- [ ] **Step 1: 实现**

`Sources/SkeletonUIKit/SkeletonOverlayView.swift`:
```swift
#if canImport(UIKit)
import UIKit
import SkeletonCore

/// 覆盖在 host 上的扫光占位层。不参与 host 的 intrinsic size；尺寸跟随 host bounds。
final class SkeletonOverlayView: UIView, ShimmerDriven {

    let configuration: SkeletonConfiguration
    private let cornerRadius: CGFloat
    /// 弱引用 host，用于读取 UILabel 的文案排版信息。
    private weak var host: UIView?

    /// 所有占位条所在的容器层；扫光 mask 作用其上。
    private let barsLayer = CALayer()
    /// 扫光高光渐变层（作为 barsLayer 的内容上方的 mask 实现，见 layout）。
    private let shimmerLayer = CAGradientLayer()
    private var lastBuiltSize: CGSize = .zero

    init(host: UIView, configuration: SkeletonConfiguration, cornerRadius: CGFloat) {
        self.host = host
        self.configuration = configuration
        self.cornerRadius = cornerRadius
        super.init(frame: host.bounds)
        isUserInteractionEnabled = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = .clear
        layer.addSublayer(barsLayer)

        shimmerLayer.colors = [UIColor.clear.cgColor,
                               configuration.highlightColor.uiColor.cgColor,
                               UIColor.clear.cgColor]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(shimmerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var shimmerConfiguration: SkeletonConfiguration { configuration }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.size != lastBuiltSize, !bounds.isEmpty else { return }
        lastBuiltSize = bounds.size
        rebuildBars()
    }

    /// 按 host 形态重建占位条：barsLayer 画底色条；shimmerLayer 覆盖 bounds 并以同形状的 mask
    /// 只在条形区域透出高光。高光的移动靠 applyShimmerPhase 改 start/endPoint（不动 frame）。
    private func rebuildBars() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        barsLayer.frame = bounds
        barsLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let base = configuration.baseColor.uiColor.cgColor
        let rects = barRects()
        let maskContainer = CALayer()
        maskContainer.frame = bounds
        for r in rects {
            let radius = min(cornerRadius, r.height / 2)
            let bar = CALayer()
            bar.frame = r
            bar.backgroundColor = base
            bar.cornerRadius = radius
            barsLayer.addSublayer(bar)

            let maskBar = CALayer()
            maskBar.frame = r
            maskBar.backgroundColor = UIColor.white.cgColor
            maskBar.cornerRadius = radius
            maskContainer.addSublayer(maskBar)
        }
        shimmerLayer.frame = bounds
        shimmerLayer.mask = maskContainer
        CATransaction.commit()
    }

    /// 计算占位条矩形：UILabel → 逐行；其它 → 单条覆盖 bounds。
    private func barRects() -> [CGRect] {
        if let label = host as? UILabel, let text = label.attributedText ?? label.text.map({
            NSAttributedString(string: $0, attributes: [.font: label.font as Any]) }) {
            let lineRects = SkeletonLineLayout.lineRects(
                for: text, width: bounds.width,
                numberOfLines: label.numberOfLines,
                lineBreakMode: label.lineBreakMode)
            return lineRects.isEmpty ? [bounds] : lineRects
        }
        return [bounds]
    }

    /// ShimmerClock 每帧回调：phase 是高光带前缘的归一化位置；通过移动渐变的 start/endPoint
    /// 让 [clear, highlight, clear] 的高光从左扫到右（与 SwiftUI 实现一致）。layer 不动，故 mask 稳定。
    func applyShimmerPhase(_ phase: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shimmerLayer.startPoint = CGPoint(x: phase, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: phase + configuration.bandWidth, y: 0.5)
        CATransaction.commit()
    }
}
#endif
```

- [ ] **Step 2: 构建校验**

Run: `xcodebuild build -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "BUILD SUCCEEDED|BUILD FAILED|error:"`
Expected: `** BUILD SUCCEEDED **`。

- [ ] **Step 3: 提交（需授权）**

```bash
git add Sources/SkeletonUIKit/SkeletonOverlayView.swift
git commit -m "feat(uikit): add SkeletonOverlayView with per-line label bars"
```

---

## Task 8: UIKit — Skeleton 入口（UIView 扩展）+ 集成测试

**Files:**
- Create: `Sources/SkeletonUIKit/Skeleton.swift`
- Test: `Tests/SkeletonUIKitTests/SkeletonUIKitTests.swift`

- [ ] **Step 1: 写失败测试**

在 `SkeletonUIKitTests.swift` 的 `#if canImport(UIKit)` 块内追加：

```swift
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
```

- [ ] **Step 2: 运行测试，确认失败**

Run: `xcodebuild test -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SkeletonUIKitTests/UIViewSkeletonTests 2>&1 | grep -E "error:|cannot find"`
Expected: 编译失败，`value of type 'UILabel' has no member 'skeleton'`。

- [ ] **Step 3: 实现**

`Sources/SkeletonUIKit/Skeleton.swift`:
```swift
#if canImport(UIKit)
import UIKit
import SkeletonCore
import ObjectiveC

/// 全局骨架外观入口。
public enum Skeleton {
    /// 全局默认外观；App 启动时可设置一次，所有 `skeleton(_:)` 默认使用。
    public static var appearance: SkeletonConfiguration = .default
}

private enum AssociatedKeys {
    static var overlay: UInt8 = 0
}

public extension UIView {
    /// active 时在自身 bounds 上叠加扫光占位（不参与 intrinsic size）；false 时移除并恢复真实内容。
    /// 尺寸完全由 host 自身内容/文案撑起；UILabel 会按文案逐行画占位条。
    /// cornerRadius 为 nil 时取 `Skeleton.appearance.cornerRadius`。
    func skeleton(_ active: Bool, cornerRadius: CGFloat? = nil) {
        if active {
            if currentSkeletonOverlay != nil { return }   // 幂等
            let config = Skeleton.appearance
            let overlay = SkeletonOverlayView(
                host: self, configuration: config,
                cornerRadius: cornerRadius ?? config.cornerRadius)
            addSubview(overlay)
            overlay.setNeedsLayout()
            overlay.layoutIfNeeded()
            ShimmerClock.shared.register(overlay)
            currentSkeletonOverlay = overlay
        } else {
            guard let overlay = currentSkeletonOverlay else { return }
            ShimmerClock.shared.unregister(overlay)
            overlay.removeFromSuperview()
            currentSkeletonOverlay = nil
        }
    }

    private var currentSkeletonOverlay: SkeletonOverlayView? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.overlay) as? SkeletonOverlayView }
        set { objc_setAssociatedObject(self, &AssociatedKeys.overlay, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
}
#endif
```

> 说明：关联对象用 `.OBJC_ASSOCIATION_ASSIGN`（弱）避免 host↔overlay 保留环；overlay 由 `addSubview` 强持有，移除即释放。

- [ ] **Step 4: 运行测试，确认通过**

Run: `xcodebuild test -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SkeletonUIKitTests/UIViewSkeletonTests 2>&1 | grep -E "Executed|TEST SUCCEEDED|TEST FAILED"`
Expected: 全部 PASS。

- [ ] **Step 5: 跑全量测试**

Run:
```bash
swift test --filter SkeletonCoreTests
xcodebuild test -scheme ISkeleton-Package -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "Executed|TEST SUCCEEDED|TEST FAILED"
```
Expected: Core（macOS）全绿；iOS 全量（含 SkeletonUIKitTests）全绿。

- [ ] **Step 6: 提交（需授权）**

```bash
git add Sources/SkeletonUIKit/Skeleton.swift Tests/SkeletonUIKitTests/SkeletonUIKitTests.swift
git commit -m "feat(uikit): add UIView.skeleton entry point with idempotent overlay"
```

---

## Task 9: README + 用法文档

**Files:**
- Create: `README.md`

> 无自动化测试；内容正确性靠人读。

- [ ] **Step 1: 写 README**

`README.md` 至少包含：
- 简介（slot 级骨架 + 全局同相位扫光，SwiftUI + UIKit）。
- 安装（SPM，三个 product：`Skeleton-Core` / `Skeleton-SwiftUI` / `Skeleton-UIKit`，import 名 `SkeletonCore`/`SkeletonSwiftUI`/`SkeletonUIKit`）。
- SwiftUI 用法（`.skeletonAppearance(_:)` + `.skeleton(active)`，强调"喂代表性内容撑尺寸"）。
- UIKit 用法（`Skeleton.appearance` + `view.skeleton(true/false)`，强调"label 用代表性文案撑尺寸与行数"）。
- 平台差异说明：SwiftUI 多行整块覆盖，UIKit 多行逐行条。
- 配置项表（baseColor/highlightColor/duration/bandWidth/cornerRadius）。

参照同目录 `ISphereCloud/README.md` 的徽章与结构风格。

- [ ] **Step 2: 提交（需授权）**

```bash
git add README.md
git commit -m "docs: add README with SwiftUI and UIKit usage"
```

---

## 完成标准

- [ ] `swift test --filter SkeletonCoreTests` 全绿（相位/配置/RGBA）。
- [ ] iOS 模拟器 `xcodebuild test`（聚合 scheme）全绿（含 `SkeletonLineLayoutTests` 与 `UIViewSkeletonTests`）。
- [ ] iOS 聚合构建 `ISkeleton-Package`（含 SwiftUI 与 UIKit 两模块）`BUILD SUCCEEDED`。
- [ ] 调用方 `import SkeletonSwiftUI` / `import SkeletonUIKit` 即可使用，无需单独 import Core（`@_exported`）。
- [ ] README 覆盖两平台用法与平台差异。
```
