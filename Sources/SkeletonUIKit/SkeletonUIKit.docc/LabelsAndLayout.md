# Labels and Layout

Derive multiline placeholder bars from the label text that reserves the loaded layout.

## Set representative text first

UIKit line geometry is text-driven. Assign the text, font, line count, and available width before activation:

```swift
bioLabel.numberOfLines = 0
bioLabel.font = .preferredFont(forTextStyle: .footnote)
bioLabel.text = representativeBiography
bioLabel.skeleton(true)
```

Changing text while the skeleton remains active does not rebuild its activation snapshot. Use this order:

```swift
bioLabel.skeleton(false)
bioLabel.text = updatedRepresentativeBiography
bioLabel.skeleton(true)
```

## Mirror TextKit line fragments

SkeletonUIKit creates an attributed value from plain label text and its current font, normalizes paragraph wrapping, and lays it out through TextKit at the label's current width. `numberOfLines == 0` returns every line required by the text instead of limiting fragments to the label's current height.

Each used line rectangle becomes one bar. The visible bar occupies 62 percent of the line fragment height and is vertically centered, leaving a gap between lines. Width follows the actual used line width, including a naturally shorter final line. The shared gradient and its mask expand to the union of the overlay bounds and every generated bar, so all content-derived bars receive shimmer. This drawing does not change the label's Auto Layout footprint.

If text is empty, width is nonpositive, or TextKit produces no line fragments, the overlay falls back to one bounds-filling geometric bar.

## Hide and restore plain text color

Activation stores a `UILabel`'s `textColor` in associated storage and sets it to clear so real text does not show beneath the shimmer. Deactivation restores the exact saved color once.

Attributed strings with explicit foreground-color attributes are outside this mechanism: clearing `textColor` cannot override those embedded colors. Avoid explicit attributed foreground colors for labels that use this skeleton path.

Dynamic type works through the label's current preferred font. Rebuild an active skeleton after a content-size-category change when its captured line layout must update immediately.
