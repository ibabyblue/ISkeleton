# Text and Sizing

Match loading geometry to the text and layout that will replace it.

## Preserve representative content

`skeleton(_:shape:textStyle:)` hides the real view rather than replacing its layout. This makes transitions stable only when the hidden view already has an appropriate footprint.

Use representative strings for data-driven labels:

```swift
Text(model?.price ?? "$00.00")
    .font(.headline)
    .skeleton(model == nil)
```

For an unloaded list, render a fixed number of placeholder rows instead of an empty collection. For an avatar or thumbnail, use a fixed frame.

## Render multiline bars

Pass the same semantic text style to `.font` and `textStyle`:

```swift
Text(model?.description ?? representativeDescription)
    .font(.footnote)
    .skeleton(model == nil, textStyle: .footnote)
```

SkeletonSwiftUI resolves the current dynamic line height through the native preferred font API, divides the hidden footprint height by that line height, and rounds to the nearest line. Each bar occupies approximately 70 percent of a line box, and the last of multiple bars uses 60 percent width.

## Avoid the collapse problem

When a hidden view has zero width or height, its overlay also has zero area. The skeleton cannot infer a future layout from absent data. Choose one of these sources of truth:

- representative text for data-driven dimensions;
- explicit frames for fixed-size visual regions;
- placeholder rows for unloaded collections;
- a deliberate line count or representative paragraph for multiline text.

Dynamic type changes are reflected through semantic text-style metrics. Avoid pairing `.font(.headline)` with `textStyle: .footnote`, because the bar count will be derived from a different line height than the hidden text.
