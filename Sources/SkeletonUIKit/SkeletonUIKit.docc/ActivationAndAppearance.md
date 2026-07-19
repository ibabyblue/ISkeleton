# Activation and Appearance

Understand configuration precedence, idempotence, and cleanup for UIKit views.

## Resolve appearance once per activation

The geometric and image-mask overloads accept an optional per-call `appearance`. Resolution follows this order:

1. Use the supplied per-call ``SkeletonConfiguration``.
2. Otherwise snapshot ``Skeleton/appearance``.

```swift
priceLabel.skeleton(true, appearance: promotionalAppearance)
nameLabel.skeleton(true)
```

An overlay retains its configuration for its lifetime. To apply a new value, deactivate and activate again.

## Treat activation as idempotent

Calling `skeleton(true)` when this view already owns an attached overlay returns without replacing it. Calling `skeleton(false)` removes any overlay and safely does nothing when none exists.

Geometric and image-mask activation share the same overlay slot. Deactivate before switching between them; otherwise the existing overlay wins the idempotence check.

## Keep all mutation on the main actor

``Skeleton`` and the `UIView` skeleton methods are main-actor isolated. They add and remove views, update layer trees, access labels, register with the display link, and use Objective-C associated storage.

Call them from UIKit lifecycle and view-configuration code on the main actor. Do not attempt to activate or change global appearance from a background task.

## Clean up completely

Deactivation:

- restores a saved label text color;
- unregisters the overlay from the shared clock;
- removes the overlay from its superview;
- clears associated overlay storage.

Label restoration runs even when overlay storage is already absent, so stale visual state does not depend on a matching overlay object.
