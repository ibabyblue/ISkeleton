# ``SkeletonCore``

Share skeleton appearance, shape, shimmer, and multiline geometry across framework integrations.

## Overview

SkeletonCore contains the platform-neutral values and calculations used by both SkeletonSwiftUI and SkeletonUIKit. Configure colors and animation once, choose a placeholder shape, and rely on the same phase and line geometry across framework boundaries.

```swift
import SkeletonCore

let appearance = SkeletonConfiguration(
    baseColor: SkeletonRGBA(r: 0.91, g: 0.85, b: 0.85, a: 0.8),
    highlightColor: SkeletonRGBA(r: 0.99, g: 0.98, b: 0.98, a: 0.8),
    duration: 1.4,
    bandWidth: 0.6,
    cornerRadius: 5,
    direction: .leftToRight
)
```

SkeletonCore does not render views or own animation lifecycle. Import SkeletonSwiftUI or SkeletonUIKit in application code to display placeholders.

## Topics

### Essentials

- <doc:ConfigurationAndColor>
- ``SkeletonConfiguration``
- ``SkeletonRGBA``

### Geometry

- <doc:ShapesAndDirections>
- ``SkeletonShape``
- ``ShimmerDirection``

### Animation and Text

- <doc:PhaseAndLineMetrics>
- ``ShimmerPhase``
- ``SkeletonLineMetrics``
