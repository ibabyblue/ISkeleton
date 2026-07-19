# SwiftUI Quick Start

Preserve each content slot's footprint and toggle its shimmer independently.

## Import the SwiftUI product

Link the `Skeleton-SwiftUI` product and import its module. SkeletonSwiftUI re-exports SkeletonCore, so configuration, color, shape, and direction types are immediately available.

```swift
import SkeletonSwiftUI
import SwiftUI
```

## Reserve the loaded footprint

Skeletons use the original view's layout size. Supply representative content while data is unavailable:

```swift
struct ProductRow: View {
    let product: Product?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .frame(width: 48, height: 48)
                .skeleton(product == nil, shape: .circle)

            VStack(alignment: .leading, spacing: 6) {
                Text(product?.name ?? "Loading product name")
                    .font(.headline)
                    .skeleton(product == nil)

                Text(product?.summary ?? "Representative two-line summary for loading content.")
                    .font(.footnote)
                    .skeleton(product == nil, textStyle: .footnote)
            }
        }
    }
}
```

An empty string has little or no footprint and cannot produce a stable placeholder. For fixed-size media, an explicit frame is sufficient.

## Configure a subtree

Apply `skeletonAppearance(_:)` near a feature or application root:

```swift
ContentView()
    .skeletonAppearance(.default)
```

Every descendant skeleton reads the same value. A nested call overrides only its own subtree.

## End the loading state

Pass `false` after the content becomes available. The modifier removes the overlay and shows the already-laid-out content without introducing another container or navigation state.
