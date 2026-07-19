# ``SkeletonSwiftUI``

Add in-place, synchronized skeleton loading states to SwiftUI content.

## Overview

SkeletonSwiftUI keeps the real view in layout, hides it while loading, and overlays a geometric, multiline, or image-masked shimmer. Appearance flows through the SwiftUI environment, allowing one application-level configuration with scoped subtree overrides.

```swift
import SkeletonSwiftUI
import SwiftUI

Text(product?.name ?? "Loading product name")
    .skeleton(product == nil)
    .skeletonAppearance(.default)
```

The host view supplies the skeleton footprint. Use representative content or an explicit frame so loading and loaded layouts occupy the same space.

## Topics

### Essentials

- <doc:SwiftUIQuickStart>

### Appearance and Geometry

- <doc:AppearanceAndShapes>
- ``SkeletonConfiguration``
- ``SkeletonShape``

### Text Layout

- <doc:TextAndSizing>

### Image Masks and Motion

- <doc:ImageMasksAndAnimation>
