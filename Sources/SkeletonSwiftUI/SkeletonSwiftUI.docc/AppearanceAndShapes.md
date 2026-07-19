# Appearance and Shapes

Share one environment configuration and select geometry per content slot.

## Inherit an appearance

`skeletonAppearance(_:)` writes `EnvironmentValues.skeletonAppearance` for its descendants. Without an explicit value, the environment uses ``SkeletonConfiguration/default``.

```swift
var appearance = SkeletonConfiguration.default
appearance.direction = .topLeftToBottomRight
appearance.duration = 1.1

ContentView()
    .skeletonAppearance(appearance)
```

Because configuration is a value type, a nested override does not mutate its ancestor:

```swift
VStack {
    PrimaryLoadingCard()

    PromotionalLoadingCard()
        .skeletonAppearance(promotionAppearance)
}
.skeletonAppearance(applicationAppearance)
```

## Choose geometric clipping

Pass a ``SkeletonShape`` to `skeleton(_:shape:textStyle:)`:

```swift
avatar
    .frame(width: 56, height: 56)
    .skeleton(isLoading, shape: .circle)

badge
    .frame(width: 120, height: 32)
    .skeleton(isLoading, shape: .capsule)

thumbnail
    .frame(width: 160, height: 96)
    .skeleton(isLoading, shape: .roundedRect(cornerRadius: 12))
```

A rounded rectangle with a `nil` radius uses the environment configuration's corner radius. Circle and capsule both use half the shorter footprint dimension; give a circle equal width and height.

## Understand shape precedence

When `textStyle` is non-`nil`, the modifier renders multiline bars and ignores `shape`. Use the shape argument only for geometric content such as avatars, thumbnails, buttons, and cards.
