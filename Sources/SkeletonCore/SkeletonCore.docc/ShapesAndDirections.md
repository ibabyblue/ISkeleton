# Shapes and Directions

Resolve placeholder clipping and shimmer axes from platform-neutral geometry.

## Choose a shape

``SkeletonShape`` supports three clipping rules:

- ``SkeletonShape/roundedRect(cornerRadius:)`` uses its explicit radius or the active configuration's fallback.
- ``SkeletonShape/circle`` uses half the shorter dimension.
- ``SkeletonShape/capsule`` also uses half the shorter dimension.

```swift
let radius = SkeletonShape.circle.cornerRadius(
    for: CGSize(width: 56, height: 56),
    default: 5
)
```

Circle and capsule share the same corner-radius calculation. Their visual distinction comes from the host footprint: use equal width and height for a circle and an elongated footprint for a capsule.

## Select a sweep direction

``ShimmerDirection`` defines normalized start and end points for four edge-to-edge and four diagonal directions. Every coordinate lies in the unit square, so rendering integrations can map the same geometry to SwiftUI gradients and Core Animation layers.

```swift
let direction = ShimmerDirection.bottomLeftToTopRight
let points = direction.gradientPoints(phase: 0.2, bandWidth: 0.6)
```

``ShimmerDirection/gradientPoints(phase:bandWidth:)`` interpolates both gradient endpoints along the selected axis. The first endpoint uses `phase`; the second uses `phase + bandWidth`. Values may fall outside `0...1` while the band enters or leaves the placeholder, which is required for a complete offscreen-to-offscreen sweep.

## Keep framework output equivalent

SwiftUI and UIKit consume the same normalized points. A direction change therefore affects both integrations consistently without framework-specific direction mapping.
