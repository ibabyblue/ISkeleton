# Image Masks and Clock

Clip a shimmer to bitmap alpha and synchronize every active UIKit overlay.

## Choose an image source

``SkeletonMask/image(_:)`` uses an explicit `UIImage`. ``SkeletonMask/ownImage`` reads the current image only when the receiver is a `UIImageView`:

```swift
logoImageView.skeleton(true, mask: .ownImage)
otherView.skeleton(true, mask: .image(maskImage))
```

Core Animation requires a bitmap-backed `CGImage`. A missing image, `.ownImage` on another view type, or a vector-only image with no `CGImage` leaves the view unchanged. Rasterize SF Symbols and PDF/vector assets before using them as UIKit masks.

The overlay fills its bounds with the base and highlight layers, then clips the combined result through the image alpha using aspect-fit content gravity. Transparent pixels hide the skeleton; opaque pixels reveal it.

## Share one weak clock

Every overlay registers with one main-actor display-link clock. The clock stores consumers weakly, calculates a single phase from Foundation reference time for each frame, and applies that phase using each overlay's snapshotted duration and band width.

The display link starts only when at least one live overlay is registered and stops after the weak collection becomes empty. A proxy prevents the display link from retaining the clock through its target.

## Resume from the foreground

UIKit may pause a display link while an application is inactive. On `UIApplication.willEnterForegroundNotification`, the clock invalidates its old link and starts a replacement only if a live overlay still needs frames.

SwiftUI computes phase from the same absolute-time function, so UIKit and SwiftUI placeholders stay in phase even though one uses `CADisplayLink` and the other uses `TimelineView`.

## Follow bounds changes

An overlay uses flexible width and height autoresizing and rebuilds its layers only when it receives a different nonempty bounds size. It never contributes intrinsic content size or intercepts user interaction.
