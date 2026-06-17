# ISkeleton

A shimmer "skeleton" loading package for SwiftUI and UIKit. ISkeleton works at the **slot
level**: each real view renders a shimmering placeholder while its data is pending, then swaps
to the real content the moment that data arrives. All shimmers across both frameworks animate
**in phase** off a shared time-based clock, so the whole screen breathes together. Pure
Swift, zero third-party dependencies.

![iOS 15+](https://img.shields.io/badge/iOS-15%2B-blue)
![Swift 5.10](https://img.shields.io/badge/Swift-5.10%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Features

- **Slot-level skeleton** — there is no full-screen "loading view." Every real view (label,
  image, card) draws its own shimmer placeholder while pending, and you flip it off per-slot as
  data lands.
- **Content-driven sizing** — the placeholder's size comes from the *view's own content*, never
  from absent data. Feed a representative value while loading and the skeleton matches the real
  layout exactly, so nothing reflows when data arrives.
- **In-phase shimmer** — both frameworks read the same `ShimmerPhase` from a single time source,
  so every placeholder's highlight band moves together.
- **SwiftUI + UIKit** — idiomatic API on each side: a `View` modifier and a `UIView` method.
- **Per-line UILabel bars** — a multi-line `UILabel` placeholder draws one shimmer bar per text
  line, mirroring how the real text will wrap.

## Requirements

| | Minimum |
|---|---|
| iOS | 15.0 |
| macOS | 12.0 |
| Swift | 5.10 |

## Installation

### Swift Package Manager

In Xcode choose **File → Add Package Dependencies**, enter the repository URL, or add to
`Package.swift`. The package ships three products:

| Product | Module | Use when |
|---|---|---|
| `Skeleton-Core` | `SkeletonCore` | Shared config / color / phase types only |
| `Skeleton-SwiftUI` | `SkeletonSwiftUI` | Building SwiftUI views |
| `Skeleton-UIKit` | `SkeletonUIKit` | Building UIKit views |

`Skeleton-SwiftUI` and `Skeleton-UIKit` each `@_exported import SkeletonCore`, so importing one
of them gives you the config types too — you do not need to depend on `Skeleton-Core` directly.

```swift
dependencies: [
    .package(url: "https://github.com/ibabyblue/ISkeleton", from: "0.2.0")
],
targets: [
    .target(name: "YourTarget", dependencies: [
        // pick the one(s) you need
        .product(name: "Skeleton-SwiftUI", package: "ISkeleton"),
        .product(name: "Skeleton-UIKit",   package: "ISkeleton"),
    ])
]
```

```swift
import SkeletonSwiftUI   // SwiftUI
import SkeletonUIKit     // UIKit
```

## SwiftUI Usage

Inject the appearance once near a root, then mark each slot active while its data is `nil`. The
key is to **feed representative content so the view reserves its real size** — bind to a typical
placeholder string instead of an empty one, otherwise the slot collapses.

```swift
import SkeletonSwiftUI

struct ProductCell: View {
    let model: Product?   // nil while loading

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Representative text gives the label its size during loading.
            Text(model?.title ?? "Loading product name")
                .skeleton(model?.title == nil)

            Text(model?.price ?? "￥00.00")
                .font(.headline)
                .skeleton(model?.price == nil)
        }
        // Inject appearance for the whole subtree (optional; .default otherwise).
        .skeletonAppearance(.default)
    }
}
```

Use `shape:` to control the placeholder outline and `textStyle:` to draw a multi-line text
placeholder:

```swift
// 圆形头像（shape: .circle）
Circle().frame(width: 56, height: 56)
    .skeleton(isLoading, shape: .circle)

// 多行文本：占位文案折几行，骨架就画几条（条数 = footprint 高度 ÷ 行高）
Text(bio).skeleton(isLoading, textStyle: .footnote)
```

A complete card — circle avatar, single-line name/price, multi-line bio — mirroring the demo:

```swift
import SkeletonSwiftUI

struct ProfileCard: View {
    let profile: Profile?                       // nil while loading
    private var isLoading: Bool { profile == nil }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle().frame(width: 56, height: 56)
                .skeleton(isLoading, shape: .circle)               // 圆形头像

            VStack(alignment: .leading, spacing: 8) {
                Text(profile?.name ?? "Loading name")              // 单行：跟随文本尺寸
                    .font(.headline)
                    .skeleton(isLoading)

                Text(profile?.price ?? "￥00.00")
                    .font(.subheadline)
                    .skeleton(isLoading)

                // 多行：喂一段「折行数与真实数据相近」的占位，shimmer 行数才会对得上
                Text(profile?.bio ?? "热爱旅行与摄影，周末喜欢去山里露营，记录值得纪念的瞬间。")
                    .font(.footnote)
                    .skeleton(isLoading, textStyle: .footnote)     // textStyle 要与 .font 一致
            }
        }
        .skeletonAppearance(.default)
    }
}
```

> Multi-line tip: the bar count comes from how the *placeholder* wraps, since the real data isn't
> loaded yet. Feed a representative string whose line count matches the typical real text, and pass
> the **same** text style to `.font` and `textStyle:` so the line height lines up.

`.skeleton(_ active: Bool, shape: SkeletonShape = ..., textStyle: Font.TextStyle? = nil)` hides the real content,
keeps its footprint, and overlays the shimmer. The `skeleton(_:shape:textStyle:)` signature replaces
the old `cornerRadius:` parameter — pass `shape: .roundedRect(cornerRadius:)` for a custom corner
radius, or `shape: .circle` for a circular placeholder. When the shape is left at its default the
appearance's `cornerRadius` applies. `.skeletonAppearance(_:)` injects a `SkeletonConfiguration`
into the environment; every `.skeleton` in the subtree reuses it.

## UIKit Usage

Set the global appearance once at launch, then drive each view's skeleton with
`skeleton(_:)`. As in SwiftUI, set representative text **first** so the view has a real size and
line count, then activate.

```swift
import SkeletonUIKit

// At app launch, once:
Skeleton.appearance = .default
```

A complete card configure — same slots as the SwiftUI example. Note the contract: **set
representative text first, then activate**; `bioLabel.numberOfLines = 0` so it wraps freely.

```swift
// bioLabel.numberOfLines = 0  // configured once at setup

func configure(with profile: Profile?) {
    if let profile {                                   // data arrived → real content
        avatarView.skeleton(false)
        nameLabel.skeleton(false);  nameLabel.text  = profile.name
        priceLabel.skeleton(false); priceLabel.text = profile.price
        bioLabel.skeleton(false);   bioLabel.text   = profile.bio
    } else {                                           // loading → representative text FIRST
        nameLabel.text  = "Loading name"
        priceLabel.text = "￥00.00"
        bioLabel.text   = "热爱旅行与摄影，周末喜欢去山里露营，记录值得纪念的瞬间。"
        avatarView.skeleton(true, shape: .circle)      // 圆形头像
        nameLabel.skeleton(true)
        priceLabel.skeleton(true)
        bioLabel.skeleton(true)                        // numberOfLines = 0 → 按真实文本逐行画条
    }
}
```

Per-call override — pass `appearance:` to use a custom appearance for just this activation, while
everything else keeps the global default:

```swift
let promo = SkeletonConfiguration(
    baseColor:      SkeletonRGBA(r: 0.96, g: 0.86, b: 0.86, a: 0.9),
    highlightColor: SkeletonRGBA(r: 1.0,  g: 0.95, b: 0.95, a: 0.9))

bioLabel.skeleton(true, appearance: promo)   // 这个视图用 promo 外观
priceLabel.skeleton(true)                    // 其它仍用全局 Skeleton.appearance
```

**Contract — set text first, toggle to change text:** `skeleton(true)` snapshots the host's
size and line count at the moment you activate it. So always set representative text *before*
calling `skeleton(true)`. To change the text while a skeleton is already active, deactivate
first: `skeleton(false)` → set the new text → `skeleton(true)`. (Reactivating with the same
state is idempotent and safe.)

`skeleton(_ active: Bool, shape: SkeletonShape = ..., appearance: SkeletonConfiguration? = nil)`
overlays the shimmer on the view's own `bounds` without affecting its intrinsic size. `appearance`
overrides `Skeleton.appearance` for that activation only (omit it to use the global default); the
default shape falls back to the resolved appearance's `cornerRadius`, while `shape: .circle` clips
to a circle. For a multi-line `UILabel`, the placeholder draws one bar per text line. Set
`Skeleton.appearance` on the main thread.

UIKit hides a `UILabel`'s text while the skeleton is active and restores it on deactivate, so the
placeholder text never shows through under the shimmer. `attributedText` with explicit colors is
out of scope.

## Configuration

`SkeletonConfiguration` controls appearance and shimmer for both frameworks (`.default` shown):

| Field | Type | Default | Meaning |
|---|---|---|---|
| `baseColor` | `SkeletonRGBA` | neutral grey | Placeholder fill color |
| `highlightColor` | `SkeletonRGBA` | near-white | Moving highlight band color |
| `duration` | `TimeInterval` | `1.4` | One full sweep, in seconds |
| `bandWidth` | `CGFloat` | `0.6` | Highlight band width, normalized to the slot |
| `cornerRadius` | `CGFloat` | `5` | Default placeholder corner radius |
| `direction` | `ShimmerDirection` | `.leftToRight` | Shimmer sweep direction (8 presets, incl. diagonals) |

Colors are platform-neutral: `SkeletonRGBA(r:g:b:a:)` with each component in `0...1` (`a`
defaults to `1`). Build a custom appearance like so:

```swift
let config = SkeletonConfiguration(
    baseColor:      SkeletonRGBA(r: 0.91, g: 0.85, b: 0.85, a: 0.8),
    highlightColor: SkeletonRGBA(r: 0.99, g: 0.98, b: 0.98, a: 0.8),
    duration:       1.4,
    bandWidth:      0.6,
    cornerRadius:   5
)

// SwiftUI: .skeletonAppearance(config)
// UIKit:   Skeleton.appearance = config
```

`direction` controls the shimmer sweep — `.leftToRight` (default), the other three edges
(`.rightToLeft`, `.topToBottom`, `.bottomToTop`), or the four diagonals such as
`.topRightToBottomLeft` (top-right → bottom-left):

```swift
var config = SkeletonConfiguration.default
config.direction = .topRightToBottomLeft   // 斜向扫光：右上 → 左下
```

## Platform Differences

Multi-line text is the one place the two frameworks intentionally diverge:

- **SwiftUI** takes a `textStyle:` and derives the line count automatically: it divides the
  hidden content's footprint height by that text style's line height, so the number of bars
  matches how the real text actually wraps. Each bar is the height of a glyph body with a gap.
- **UIKit** is **text-driven**: a multi-line `UILabel` draws **one bar per text line**
  automatically, because UIKit *does* expose per-line layout, so the placeholder mirrors the real
  wrap. Each bar is shrunk slightly to leave gaps between lines.

Single-line slots look identical on both sides.

## The "collapse" problem

The skeleton's size must come from the **view's own content, never from absent data**. If you
render a skeleton over a view whose data is `nil`, the view has nothing to size itself from and
collapses to zero — the shimmer disappears or jumps when real data arrives. Rules of thumb:

- **Empty list** → don't render zero rows; render *N placeholder items* and skeleton each one.
- **Data-driven width** (a price, a name) → bind to a *representative string* (`"￥00.00"`)
  while loading so the label reserves real width.
- **Multi-line height** → reserve a *fixed design line count* (e.g. set `numberOfLines` and a
  height), or feed *representative multi-line text*, so the block / per-line bars have height.
- **Fixed-size region** (an avatar, a thumbnail) → give it an *explicit frame*; its size is
  already content-independent.

## Demo

A runnable demo app lives in `demo/`. The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `demo/project.yml`:

```bash
cd demo
xcodegen generate   # only needed after editing project.yml
open ISkeletonDemo.xcodeproj
```

Run it on an iOS simulator. Two tabs:

- **SwiftUI** — each slot uses `.skeleton(isLoading)`; the multi-line bio uses `.skeleton(isLoading, textStyle: .footnote)` and draws one bar per wrapped line.
- **UIKit** — each control uses `view.skeleton(true/false)`; the multi-line bio `UILabel` renders one shimmer bar per text line.

Tap **Reload** in either tab to replay the loading → shimmer → real-content transition.

(The generated `ISkeletonDemo.xcodeproj` is committed, so the demo also opens without XcodeGen installed.)

## License

MIT.
