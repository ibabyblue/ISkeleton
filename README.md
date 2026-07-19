# ISkeleton

ISkeleton is a zero-dependency Swift package for synchronized, slot-level skeleton loading states in SwiftUI and UIKit. Each placeholder keeps the real view's footprint, while both framework integrations derive shimmer phase from the same absolute-time calculation.

![iOS 15+](https://img.shields.io/badge/iOS-15%2B-blue)
![macOS 12+](https://img.shields.io/badge/macOS-12%2B-blue)
![Swift 5.10+](https://img.shields.io/badge/Swift-5.10%2B-orange)
![SPM](https://img.shields.io/badge/SPM-compatible-brightgreen)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

## Features

- Slot-level placeholders that preserve the loaded layout
- In-phase shimmer across SwiftUI and UIKit
- Rounded rectangle, circle, and capsule shapes
- Eight horizontal, vertical, and diagonal sweep directions
- Content-driven multiline text bars
- Transparent-image alpha masks for logos and silhouettes
- Environment-scoped SwiftUI appearance and nested overrides
- Global UIKit appearance and per-activation overrides
- Dynamic type support and main-actor UIKit lifecycle handling
- No external dependencies

## Requirements

| Toolchain or platform | Minimum |
| --- | --- |
| iOS | 15.0 |
| macOS | 12.0 |
| Swift | 5.10 |
| Xcode | 15.3 or newer |

## Installation

Add `https://github.com/ibabyblue/ISkeleton.git` through Xcode's package dependency interface and select version `0.4.0` or later, or add it to `Package.swift`:

```swift
dependencies: [
    .package(
        url: "https://github.com/ibabyblue/ISkeleton.git",
        from: "0.4.0"
    )
]
```

Choose the product that owns your integration:

| Product | Module | Purpose |
| --- | --- | --- |
| `Skeleton-Core` | `SkeletonCore` | Platform-neutral configuration, colors, shapes, phase, and geometry |
| `Skeleton-SwiftUI` | `SkeletonSwiftUI` | SwiftUI modifiers, environment appearance, text metrics, and image masks |
| `Skeleton-UIKit` | `SkeletonUIKit` | UIKit overlays, label layout, image masks, and shared display-link lifecycle |

The SwiftUI and UIKit modules re-export SkeletonCore, so application targets normally link only the framework products they use.

## SwiftUI Quick Start

Feed representative content while data is unavailable so the hidden view reserves its loaded size:

```swift
import SkeletonSwiftUI
import SwiftUI

struct ProductTitle: View {
    let title: String?

    var body: some View {
        Text(title ?? "Loading product name")
            .font(.headline)
            .skeleton(title == nil)
            .skeletonAppearance(.default)
    }
}
```

Use the same semantic style for multiline text:

```swift
Text(summary ?? representativeSummary)
    .font(.footnote)
    .skeleton(summary == nil, textStyle: .footnote)
```

## UIKit Quick Start

UIKit snapshots label layout and appearance when a skeleton activates. Deactivate before changing content or configuration:

```swift
import SkeletonUIKit

@MainActor
func configureTitle(_ title: String?) {
    titleLabel.skeleton(false)

    if let title {
        titleLabel.text = title
    } else {
        titleLabel.text = "Loading product name"
        titleLabel.skeleton(true)
    }
}
```

Set a global appearance once with `Skeleton.appearance`, or pass `appearance:` for one activation.

## Shapes and Image Masks

```swift
avatar.skeleton(isLoading, shape: .circle)

Image("brand-logo")
    .skeleton(isLoading, mask: Image("brand-logo"))

logoImageView.skeleton(true, mask: .ownImage)
```

Image masks use alpha. Transparent-background assets produce silhouettes; opaque images produce rectangles. UIKit requires a bitmap-backed `CGImage`, so rasterize vector assets and SF Symbols before activation.

Geometric and image-mask activation are separate rendering modes. Deactivate a UIKit view before switching between them.

## Important Sizing Contract

ISkeleton cannot infer future layout from absent data. Use representative strings for data-driven text, placeholder rows for unloaded collections, and explicit frames for fixed-size media. A view with a zero footprint produces a zero-size skeleton. Before activating a multiline UIKit label, resolve its final width; its current text, width, and `numberOfLines` determine the generated bars, and every bar participates in the shared shimmer without changing the label's layout footprint.

## Documentation

Use the target-owned DocC catalogs for complete behavior and API detail:

- [SkeletonCore](Sources/SkeletonCore/SkeletonCore.docc/SkeletonCore.md)
- [SkeletonSwiftUI](Sources/SkeletonSwiftUI/SkeletonSwiftUI.docc/SkeletonSwiftUI.md)
- [SkeletonUIKit](Sources/SkeletonUIKit/SkeletonUIKit.docc/SkeletonUIKit.md)

Build a catalog with `xcodebuild docbuild -scheme Skeleton-Core`, `Skeleton-SwiftUI`, or `Skeleton-UIKit`.

## Example

Open `Example/ISkeletonDemo.xcodeproj` to run live SwiftUI and UIKit labs for every direction, shape, theme, duration, band width, multiline layout, local override, and image-mask integration.

See the [Example guide](Example/README.md) for XcodeGen, build, and UI-test commands.

## License

ISkeleton is available under the MIT License. See [LICENSE](LICENSE).

Release history is maintained in [CHANGELOG.md](CHANGELOG.md).
