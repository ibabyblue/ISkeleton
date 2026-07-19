# ``SkeletonUIKit``

Add synchronized, content-driven skeleton overlays to UIKit views.

## Overview

SkeletonUIKit snapshots a configuration when a view activates its skeleton, overlays Core Animation layers without changing intrinsic size, and drives all live overlays from one shared display link.

```swift
import SkeletonUIKit

nameLabel.text = "Loading product name"
nameLabel.skeleton(true)
```

Set representative content and establish bounds before activation. Deactivate, update content, and reactivate when an active label's text or configuration needs to change.

## Topics

### Essentials

- <doc:UIKitQuickStart>
- ``Skeleton``

### Activation and Appearance

- <doc:ActivationAndAppearance>
- ``SkeletonConfiguration``
- ``SkeletonShape``

### Label Geometry

- <doc:LabelsAndLayout>

### Image Masks and Lifecycle

- <doc:ImageMasksAndClock>
- ``SkeletonMask``
