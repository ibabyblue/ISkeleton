# SwiftUI 文本骨架：用 TextStyle 自动计算行数

日期：2026-06-17
模块：`SkeletonSwiftUI`

## 背景与问题

当前 SwiftUI 侧 `.skeleton(active, shape:lines:)` 用 `lines: Int` 显式指定多行骨架的条数。骨架总高度来自 `.hidden()` 保留的 footprint（被隐藏真实内容的渲染高度），而 `ShimmerLines` 把这个高度**均分**为 `lines` 条：

```swift
let barH = geo.size.height / (CGFloat(n) + gapRatio * CGFloat(n - 1))
```

问题：`lines` 只决定「画几条」，单条粗细与总高跟随 footprint。当占位文案折行数（例如 6 行）与 `lines`（例如 2）对不上时，2 条被撑到约 2.5 行高，骨架「过胖」。

对比：UIKit 侧已有 `SkeletonLineLayout`，用 TextKit 按真实 `attributedText` 和宽度排版，**行数与末行宽度完全由文案决定**，无此问题。SwiftUI 的 `ViewModifier` 读不到子 View 的文本字符串，也读不到 `Font` 的行高（`Font` 不透明），因此无法像 UIKit 那样全自动。

## 目标

调用方不再指定行数。传入 `Font.TextStyle`，由其换算出单行高度，再用 footprint 高度反推行数：`行数 = footprint高度 / 单行高度`。footprint 已综合了「文案长度 + 字体 + 行距 + 列宽」，因此行数天然等于真实折行数，逐行对齐，且修复「过胖」。

## 非目标

- 不改 UIKit 侧（已自动）。
- 不读取子 View 文本内容（SwiftUI 不支持）。
- 不测试动画与具体布局像素，仅测纯函数。

## 设计

### ① API 变更（破坏性）

`Sources/SkeletonSwiftUI/SkeletonModifier.swift`

```swift
func skeleton(_ active: Bool,
              shape: SkeletonShape = .roundedRect(cornerRadius: nil),
              textStyle: Font.TextStyle? = nil) -> some View
```

- 去掉 `lines: Int`，新增 `textStyle: Font.TextStyle?`。
- 分支语义：
  - `textStyle != nil` → 文本骨架：按 footprint 高度自动算行数（忽略 `shape`）。
  - `textStyle == nil` → 图形骨架：按 `shape`（circle/capsule/roundedRect）渲染单块，用于头像等。
- 0.2.0 尚未发布正式版，破坏性变更可接受。

### ② TextStyle → 行高换算（跨平台）

新增工具（置于 `SkeletonSwiftUI`，依赖 `Font.TextStyle`）：

```swift
// Font.TextStyle → 平台原生 TextStyle → lineHeight（跟随动态字体）
#if canImport(UIKit)
UIFont.preferredFont(forTextStyle: mapped).lineHeight
#elseif canImport(AppKit)
NSFont.preferredFont(forTextStyle: mapped).boundingRectForFont.height  // 近似行高
#endif
```

- 手写 `Font.TextStyle → UIFont.TextStyle`（iOS）与 `Font.TextStyle → NSFont.TextStyle`（macOS）的 `switch`，一一对应（`.footnote → .footnote` 等）。
- 两个平台均跟随系统字号设置。
- macOS 用 `boundingRectForFont.height` 作为行高近似（无 `lineHeight` 等价物时的取值）。

### ③ 多行布局算法

`ShimmerLines` 改为接收 `lineHeight: CGFloat`（由 ② 算出），用 `GeometryReader` 拿 footprint 高度 `H`：

```
N    = max(1, round(H / lineHeight))   // 自动行数 = 真实折行数
barH = lineHeight * 0.7                // 条高 ≈ 字形主体，上下留白即行距
```

- VStack 顶对齐排 N 条，每条占 `lineHeight` 高、条本体高 `barH`、圆角 `min(config.cornerRadius, barH / 2)`。
- 末行宽 = `width * 0.6`，其余满宽（沿用现状）。
- `H` 非整数倍时按 `round` 取整，底部余量留白（真实文本同样顶部起排，视觉吻合）。
- 同相位扫光逻辑不变。

### ④ demo + 测试

- demo：`SwiftUIDemoView.swift` 的 bio 改 `.skeleton(isLoading, textStyle: .footnote)`。`placeholderBio` 可保留长文案——行数随 footprint 自动变化，长文案多行、短文案少行，不再撑胖。
- 测试：将「`Font.TextStyle → 行高`」与「`H → N` 取整」抽为纯函数并加单元测试。布局/动画不测。

## 权衡

- `shape` 与 `textStyle` 两个默认参数语义互斥（传 textStyle 时 shape 被忽略），略不正交，但默认值使常见调用清晰，且优于把 `Font.TextStyle` 塞进跨模块的 `SkeletonCore.SkeletonShape`（Core 不应依赖 SwiftUI 类型）。
- `barH = lineHeight * 0.7` 为经验系数，近似 cap/x-height，后续可按观感微调。
- macOS 行高用 `boundingRectForFont.height` 与 iOS `lineHeight` 不完全一致，但 demo 与主要场景为 iOS，差异可接受。
