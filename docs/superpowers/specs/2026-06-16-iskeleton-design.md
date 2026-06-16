# ISkeleton 设计

- 日期：2026-06-16
- 状态：已通过 brainstorm 评审，待写实现计划
- 作者：ibabyblue

## 1. 背景与目标

把 mira-ios 中验证过的"逐控件骨架"模式（`StarsDealCardView` 的 slot 级骨架、`ShimmerModifier` 扫光）
抽成一个独立 SPM 包 **ISkeleton**，同时提供 SwiftUI 与 UIKit 两套 API。

核心诉求：**设计稿里每个真实展示的 view 上都有 shimmer，控件拿到真实数据时 shimmer 消失、展示真实数据。**

核心难点：**有些 view 要靠数据撑起尺寸，没数据就塌陷、看不见 shimmer。**

解决原则（贯穿全包）：

> **骨架的尺寸必须由骨架自己/真实控件的内容负责，永远不依赖"已到达的真实数据"。**
> loading 期间由调用方喂入"代表性占位内容"（典型文案串等）来撑出尺寸；UIKit 下 label 的文案同时决定行数。

## 2. 非目标（YAGNI）

- 不做整屏式骨架协调器（mira 已有 `FeedSkeletonView` + SkeletonView 库覆盖该场景）。
- 不做网络/数据加载、不做"占位假数据生成器"（代表性内容由调用方提供）。
- 不替代 `MShimmerLabel`（那是"真实文字发光/streaming"用途，与"空骨架"不同）。
- v1 不做骨架出现/消失的淡入淡出过渡（直接切换）。

## 3. 包结构与命名（方案 A）

包目录：`/Users/zhangbiao/work/other/ios_modules/ISkeleton`（与 ISphereCloud 平级的独立仓库）。

3 个 target（module 名为合法标识符，CamelCase）：

| module（`import`） | product（外部依赖名） | 依赖 | 平台 |
|---|---|---|---|
| `SkeletonCore` | `Skeleton-Core` | — | 跨平台（Foundation/CoreGraphics） |
| `SkeletonSwiftUI` | `Skeleton-SwiftUI` | SkeletonCore | iOS（SwiftUI） |
| `SkeletonUIKit` | `Skeleton-UIKit` | SkeletonCore | iOS（UIKit） |

- 平台 module 内 `@_exported import SkeletonCore`，使调用方 `import SkeletonSwiftUI` / `import SkeletonUIKit`
  即可直接使用 `SkeletonConfiguration` / `SkeletonRGBA`，无需再单独 import Core。
- `Package.swift`：`swift-tools-version:5.10`，`platforms: [.iOS(.v15)]`
  （`TimelineView(.animation)` 需 iOS 15+；落地时按 mira-ios 实际部署目标对齐）。
- 测试 target：`SkeletonCoreTests`（跨平台，`swift test` 可跑）、`SkeletonUIKitTests`（iOS 模拟器）。

## 4. SkeletonCore（纯逻辑，可单测）

平台无关，不引入任何 UI 框架。

### 4.1 SkeletonRGBA

```swift
public struct SkeletonRGBA: Equatable {
    public var r, g, b, a: Double   // 各分量 0...1
    public init(r: Double, g: Double, b: Double, a: Double = 1)
}
```
各平台 target 提供转换扩展：`SkeletonRGBA → SwiftUI.Color`、`→ UIColor`。

### 4.2 SkeletonConfiguration

```swift
public struct SkeletonConfiguration {
    public var baseColor: SkeletonRGBA       // 占位条底色
    public var highlightColor: SkeletonRGBA  // 扫光高光色
    public var duration: TimeInterval        // 单次扫光时长，默认 1.4
    public var bandWidth: CGFloat            // 高光带归一化宽度，默认 0.6
    public var cornerRadius: CGFloat         // 占位条默认圆角，默认 5
    public init(...)
    public static let `default`: SkeletonConfiguration
}
```
默认 `baseColor`/`highlightColor` 取一组中性灰（具体值实现期定，文档注明对应 mira 现用色可由调用方覆盖）。

### 4.3 ShimmerPhase（全局同相位的关键）

```swift
public enum ShimmerPhase {
    /// 由"绝对时间"映射出扫光高光带的起始归一化位置。
    /// 返回 band 前缘 x：从 -bandWidth（band 全在左侧外）线性走到 1（band 全在右侧外），按 duration 循环，无缝。
    /// band 区间为 [phase, phase + bandWidth]。
    public static func phase(at time: TimeInterval,
                             duration: TimeInterval,
                             bandWidth: CGFloat) -> CGFloat
}
```
实现：`let t = time.truncatingRemainder(dividingBy: duration) / duration`（0..<1）；
`return -bandWidth + CGFloat(t) * (1 + bandWidth)`。

**全局同相位**：SwiftUI 与 UIKit 都以 `Date().timeIntervalSinceReferenceDate` 为同一时间基准代入本函数，
因此所有骨架（甚至跨框架同屏）相位一致。

## 5. SkeletonSwiftUI

### 5.1 外观注入（Environment）

```swift
public extension View {
    /// 注入骨架外观；子树内所有 .skeleton 复用之。未注入时用 SkeletonConfiguration.default。
    func skeletonAppearance(_ config: SkeletonConfiguration) -> some View
}
```

### 5.2 修饰器

```swift
public extension View {
    /// active 时：隐藏真实内容但保留其 footprint，叠加圆角扫光占位；false 时原样显示真实内容。
    /// cornerRadius 为 nil 时取外观配置的 cornerRadius。
    func skeleton(_ active: Bool, cornerRadius: CGFloat? = nil) -> some View
}
```

行为：
- `active == false` → 直接返回 `content`。
- `active == true` → `content.hidden().overlay { ShimmerPlaceholder(config, cornerRadius) }`。
  - 尺寸由 `content`（调用方喂的代表性内容）经 `.hidden()` 保留。
- `ShimmerPlaceholder`：`RoundedRectangle(cornerRadius).fill(base)`，其上用
  `TimelineView(.animation)` 读 `context.date.timeIntervalSinceReferenceDate` → `ShimmerPhase.phase(...)`
  → 一条 `LinearGradient([clear, highlight, clear], start:(p,0.5), end:(p+bandWidth,0.5))`，
  裁到同一圆角矩形。各 `TimelineView` 独立但同时钟 ⇒ 同相位。

### 5.3 多行

SwiftUI 取不到行片段信息，v1 **整块圆角覆盖**（`.hidden()` 已保留多行高度，盖一整块）。
逐行条为 UIKit 专属能力（见 §6.3）。此平台不对称是 v1 的有意取舍。

## 6. SkeletonUIKit（核心）

### 6.1 全局外观与 API

```swift
public enum Skeleton {
    /// 全局默认外观；可在 App 启动时设置一次。
    public static var appearance: SkeletonConfiguration
}

public extension UIView {
    /// active 时在自身 bounds 上叠加扫光占位（不参与 intrinsic size）；false 时移除并恢复真实内容。
    /// cornerRadius 为 nil 时取 Skeleton.appearance.cornerRadius。
    func skeleton(_ active: Bool, cornerRadius: CGFloat? = nil)
}
```

尺寸完全由 host view 自身内容/文案撑起，**不写死任何约束**。

### 6.2 SkeletonOverlayView

- `skeleton(true)`：查找/创建一个 `SkeletonOverlayView`，作为 host 的 subview，
  frame 跟随 host `bounds`（`autoresizingMask = [.flexibleWidth, .flexibleHeight]`），
  `isUserInteractionEnabled = false`。用关联对象（associated object）记录引用，保证幂等（重复 true 复用）。
- `skeleton(false)`：从 `ShimmerClock` 注销 → 从父视图移除 overlay → 清关联对象。
- overlay 不透明，盖住 host 内容；**不改写 host 自身**（host 的真实文案/图片保持原样，仅被覆盖）。
- overlay 在自身 `layoutSubviews` 中根据 host 形态重建占位条（bounds/文案变化时刷新）。

### 6.3 占位条形态

- **host 是 UILabel** → 逐行条：
  - 用 TextKit（`NSTextStorage` + `NSLayoutManager` + `NSTextContainer`，容器宽 = label `bounds.width`，
    `maximumNumberOfLines = label.numberOfLines`，`lineBreakMode` 对齐 label）装入 label 的
    `attributedText`（或 `text`+`font`），`enumerateLineFragments` 取每行 used rect。
  - 每行画一条圆角占位条：非末行用满行宽，末行用该行实际宽度（≈末行文字宽）。
  - 行数由文案决定 ⇒ 完全符合"label 由文案撑起来"。
- **host 是其它 UIView**（image/button/自定义）→ 单条圆角，覆盖 bounds。

### 6.4 扫光与全局时钟 ShimmerClock

```swift
final class ShimmerClock {           // internal 单例
    static let shared: ShimmerClock
    func register(_ overlay: SkeletonOverlayView)
    func unregister(_ overlay: SkeletonOverlayView)
}
```
- 单例持有**一条** `CADisplayLink`；用 `NSHashTable.weakObjects()` 弱引用所有激活的 overlay。
- 每帧：用 `ShimmerPhase.phase(at: Date().timeIntervalSinceReferenceDate, ...)` 算统一相位，
  推给每个 overlay 的扫光 `CAGradientLayer`（设置其 position，`CATransaction` 关隐式动画）⇒ 全局同相位。
- 首个 overlay 注册时启动 link，最后一个注销时 `invalidate` 停表（空转即停）。
- 复用 `MShimmerLabel` 已验证的前后台处理：`willEnterForeground` 时重置/重配，避免回前台动画停滞。
- link 用弱代理（参照 mira/ISphereCloud 的 `DisplayLinkProxy` 范式）避免 link 强引用单例导致的生命周期问题。

## 7. 调用示例

SwiftUI：
```swift
Text(product?.priceText ?? "￥00.00")     // 代表性占位内容撑尺寸
    .skeleton(product?.price == nil)
```

UIKit：
```swift
priceLabel.text = product?.priceText ?? "￥00.00"   // 代表性占位文案撑尺寸与行数
priceLabel.skeleton(product == nil)
// 数据到达：
priceLabel.text = product.priceText
priceLabel.skeleton(false)
```

## 8. 测试策略

- **SkeletonCore（macOS `swift test`）**：
  - `ShimmerPhase.phase`：`t=0` 处返回 `-bandWidth`；接近 `duration` 处接近 `1`；单调递增；按 duration 循环。
  - `SkeletonConfiguration.default` 字段值；`SkeletonRGBA` 初始化与默认 alpha。
- **SkeletonUIKit（iOS 模拟器 xcodebuild test）**：
  - 多行行数与末行宽度：给定文案/字体/宽度，TextKit 计算的行数与末行宽度符合预期。
  - `skeleton(true)` 后 host 多出一个 `SkeletonOverlayView` subview；`skeleton(false)` 后移除；重复 true 幂等。
  - `ShimmerClock` 注册启动、全部注销后停表；overlay 释放后弱表自动清理。
- **SkeletonSwiftUI**：相位/外观环境注入等可纯验证的部分（视图快照不做）。

## 9. 边界与稳定性

- `skeleton(true)` 幂等；快速 true/false 切换不残留 overlay。
- host bounds 为 0（无代表性内容）→ overlay 为空、不绘制；这是调用方未喂占位内容所致，文档明确。
- UILabel 用 `attributedText` 时按其排版计算；`numberOfLines` 限制被尊重。
- overlay 与 `ShimmerClock` 均弱引用，无保留环；host 释放即整体释放。
- 颜色随 `SkeletonConfiguration`，深浅色由调用方配置决定。

## 10. 关键取舍

- 调用方负责"代表性占位内容"——slot 级骨架的本质要求，非缺陷。
- **SwiftUI 整块覆盖 / UIKit 逐行条** 的平台不对称（§5.3）：SwiftUI 无行片段 API，逐行成本高，v1 暂不做。
- 颜色用平台无关 `SkeletonRGBA`：换来 Core 纯净、可在 macOS 单测；各平台做一次转换。
- module 用 CamelCase（`import SkeletonSwiftUI`），product 用连字符（`Skeleton-SwiftUI`）以满足命名偏好。
