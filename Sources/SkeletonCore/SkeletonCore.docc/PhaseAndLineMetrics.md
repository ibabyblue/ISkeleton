# Phase and Line Metrics

Use deterministic calculations for synchronized shimmer motion and multiline placeholders.

## Calculate a shared phase

``ShimmerPhase/phase(at:duration:bandWidth:)`` maps an absolute time to the leading edge of the highlight band. Over one duration, the phase moves from `-bandWidth` to `1` and then repeats.

```swift
let phase = ShimmerPhase.phase(
    at: Date().timeIntervalSinceReferenceDate,
    duration: appearance.duration,
    bandWidth: appearance.bandWidth
)
```

SwiftUI and UIKit use the same Foundation reference time, so independently rendered placeholders remain in phase. A nonpositive duration returns `-bandWidth`, keeping the band at its initial offscreen position instead of dividing by zero.

Negative absolute times are normalized into the same repeating cycle.

## Estimate multiline geometry

``SkeletonLineMetrics`` converts a total text footprint and a resolved framework line height into bar geometry:

```swift
let count = SkeletonLineMetrics.lineCount(
    height: footprintHeight,
    lineHeight: resolvedLineHeight
)
let height = SkeletonLineMetrics.barHeight(
    lineHeight: resolvedLineHeight
)
```

``SkeletonLineMetrics/lineCount(height:lineHeight:)`` rounds to the nearest line and always returns at least one. Nonpositive footprint or line height also produces one line.

``SkeletonLineMetrics/barHeight(lineHeight:ratio:)`` uses `0.7` of the line height by default and clamps the result to a nonnegative value. The remaining vertical space becomes the visual gap between bars.

Framework integrations remain responsible for obtaining an appropriate dynamic line height and for measuring the content footprint.
