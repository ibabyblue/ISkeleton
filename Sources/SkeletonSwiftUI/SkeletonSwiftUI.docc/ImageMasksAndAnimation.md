# Image Masks and Animation

Clip the shared shimmer to an image silhouette and keep every slot in phase.

## Use an alpha silhouette

Pass the same image, or another image with the desired alpha, to `skeleton(_:mask:)`:

```swift
Image("brand-logo")
    .resizable()
    .scaledToFit()
    .frame(width: 160, height: 48)
    .skeleton(isLoading, mask: Image("brand-logo"))
```

The modifier resizes the mask to the host footprint. Transparent pixels hide the shimmer and opaque pixels reveal it. An opaque rectangular asset produces a rectangular skeleton, so use an image with a transparent background for a logo silhouette.

The image-mask overload is separate from the geometric overload. Select one rendering path for a content slot.

## Share one time basis

Each active SwiftUI skeleton uses `TimelineView(.animation)` and converts its date through ``ShimmerPhase``. UIKit uses the same Foundation reference time, so placeholders across both integrations advance with the same phase even though their lifecycle drivers differ.

## Respond to lifecycle and appearance

SwiftUI schedules animation updates only while the timeline participates in the rendered hierarchy. Removing the skeleton modifier's active state restores the real content and removes the animated overlay.

Environment changes rebuild the rendered fill with the latest configuration. A nested appearance continues to override its parent for that subtree.

SkeletonSwiftUI supports both iOS and macOS at the package's declared platform floors. Native font mapping follows UIKit on iOS and AppKit on macOS.
