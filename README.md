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
    .package(url: "https://github.com/ibabyblue/ISkeleton", from: "0.1.0")
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

`.skeleton(_ active: Bool, cornerRadius: CGFloat? = nil)` hides the real content, keeps its
footprint, and overlays a rounded shimmer. When `cornerRadius` is `nil` it falls back to the
appearance's `cornerRadius`. `.skeletonAppearance(_:)` injects a `SkeletonConfiguration` into the
environment; every `.skeleton` in the subtree reuses it.

## UIKit Usage

Set the global appearance once at launch, then drive each view's skeleton with
`skeleton(_:)`. As in SwiftUI, set representative text **first** so the view has a real size and
line count, then activate.

```swift
import SkeletonUIKit

// At app launch, once:
Skeleton.appearance = .default

// When configuring a cell with possibly-missing data:
priceLabel.text = model?.price ?? "￥00.00"   // representative text first
priceLabel.skeleton(model == nil)             // then activate

// When the real data arrives:
priceLabel.text = model.price
priceLabel.skeleton(false)
```

**Contract — set text first, toggle to change text:** `skeleton(true)` snapshots the host's
size and line count at the moment you activate it. So always set representative text *before*
calling `skeleton(true)`. To change the text while a skeleton is already active, deactivate
first: `skeleton(false)` → set the new text → `skeleton(true)`. (Reactivating with the same
state is idempotent and safe.)

`skeleton(_ active: Bool, cornerRadius: CGFloat? = nil)` overlays the shimmer on the view's own
`bounds` without affecting its intrinsic size; `cornerRadius` falls back to
`Skeleton.appearance.cornerRadius` when `nil`. For a multi-line `UILabel`, the placeholder draws
one bar per text line.

## Configuration

`SkeletonConfiguration` controls appearance and shimmer for both frameworks (`.default` shown):

| Field | Type | Default | Meaning |
|---|---|---|---|
| `baseColor` | `SkeletonRGBA` | neutral grey | Placeholder fill color |
| `highlightColor` | `SkeletonRGBA` | near-white | Moving highlight band color |
| `duration` | `TimeInterval` | `1.4` | One full sweep, in seconds |
| `bandWidth` | `CGFloat` | `0.6` | Highlight band width, normalized to the slot |
| `cornerRadius` | `CGFloat` | `5` | Default placeholder corner radius |

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

## Platform Differences

Multi-line text is the one place the two frameworks intentionally diverge:

- **SwiftUI** draws **one block overlay** covering the reserved footprint of the slot. SwiftUI
  does not expose line-fragment introspection, so the placeholder cannot know where individual
  lines wrap — it shimmers the whole rectangle.
- **UIKit** draws **one bar per line** for a multi-line `UILabel`, because UIKit *does* expose
  per-line layout, so the placeholder can mirror the real wrap.

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

- **SwiftUI** — each slot uses `.skeleton(isLoading)`; the multi-line bio renders as a single block overlay.
- **UIKit** — each control uses `view.skeleton(true/false)`; the multi-line bio `UILabel` renders one shimmer bar per text line.

Tap **Reload** in either tab to replay the loading → shimmer → real-content transition.

(The generated `ISkeletonDemo.xcodeproj` is committed, so the demo also opens without XcodeGen installed.)

## License

MIT.
