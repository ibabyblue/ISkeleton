# Configuration and Color

Define one platform-neutral skeleton appearance for SwiftUI and UIKit.

## Configure an appearance

``SkeletonConfiguration`` stores all shared rendering inputs:

- ``SkeletonConfiguration/baseColor`` fills the placeholder.
- ``SkeletonConfiguration/highlightColor`` colors the center of the moving band.
- ``SkeletonConfiguration/duration`` is one sweep duration in seconds.
- ``SkeletonConfiguration/bandWidth`` is normalized to the sweep axis.
- ``SkeletonConfiguration/cornerRadius`` is the rounded-rectangle fallback in points.
- ``SkeletonConfiguration/direction`` selects one of eight sweep directions.

```swift
var appearance = SkeletonConfiguration.default
appearance.duration = 1.0
appearance.bandWidth = 0.45
appearance.direction = .topRightToBottomLeft
```

The configuration is a mutable value type. Copy it before changing a local variant so other consumers retain their previous values.

## Share color values

``SkeletonRGBA`` keeps color configuration independent of UIKit and SwiftUI. Each component uses the conventional `0...1` interval, and alpha defaults to `1`:

```swift
let base = SkeletonRGBA(r: 0.18, g: 0.20, b: 0.24)
let highlight = SkeletonRGBA(r: 0.42, g: 0.45, b: 0.52, a: 0.95)
```

SkeletonCore stores supplied component values without clamping. Pass values in `0...1` when the color will be converted by a framework integration.

## Start from the default

``SkeletonConfiguration/default`` provides the package's neutral gray fill, near-white highlight, `1.4`-second duration, `0.6` normalized band width, `5`-point radius, and left-to-right direction.

Use the default directly for a consistent application-wide appearance, or copy it and change only the fields required by a particular design system.
