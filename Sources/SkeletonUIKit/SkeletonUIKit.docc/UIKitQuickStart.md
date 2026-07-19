# UIKit Quick Start

Prepare a view's loaded footprint before activating its skeleton.

## Import the UIKit product

Link the `Skeleton-UIKit` product and import its module. SkeletonUIKit re-exports SkeletonCore, so shared configuration and shape types are available from the same import.

```swift
import SkeletonUIKit
```

## Set a global appearance

Set ``Skeleton/appearance`` on the main actor, normally during application setup:

```swift
Skeleton.appearance = .default
```

Each activation without a per-call override snapshots the current global value. Changing the global value does not mutate overlays that are already active.

## Activate after setting content

For a label, set representative text before calling `skeleton(true)`:

```swift
@MainActor
func configure(with product: Product?) {
    nameLabel.skeleton(false)

    if let product {
        nameLabel.text = product.name
    } else {
        nameLabel.text = "Loading product name"
        nameLabel.skeleton(true)
    }
}
```

The active overlay follows the view's bounds but captures label line layout and configuration at activation. The explicit deactivate-update-activate order keeps that snapshot accurate.

## Choose a shape

Non-label hosts use a geometric shape:

```swift
avatarView.skeleton(true, shape: .circle)
thumbnailView.skeleton(true, shape: .roundedRect(cornerRadius: 12))
```

Multiline labels use their text-driven line fragments instead of the supplied shape.
