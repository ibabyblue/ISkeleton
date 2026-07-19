# Changelog

All notable changes to ISkeleton are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses semantic versioning.

## [0.4.0] - 2026-07-19

### Added

- Added target-owned DocC catalogs for Core geometry, SwiftUI integration, and UIKit lifecycle behavior.
- Added English documentation comments for every package and Example application declaration.
- Added an Example guide, shared scheme, and offline UI coverage for the SwiftUI and UIKit labs.
- Added the repository's MIT license file.

### Changed

- Renamed the repository `demo` directory to `Example` while preserving the `ISkeletonDemo` app and target identities.
- Reorganized the root README as the concise installation and discovery entry point.
- Added deterministic accessibility identifiers for the two Example loading controls.

## [0.3.0] - 2026-06-18

### Added

- Added transparent-image alpha-mask skeletons to SwiftUI and UIKit.
- Added `.ownImage` support for bitmap-backed `UIImageView` content.
- Added matching image-mask scenarios to both Example framework labs.

### Documentation

- Documented transparent-background and bitmap requirements.
- Documented that geometric and image-mask skeleton modes are mutually exclusive per UIKit view activation.

## [0.2.0] - 2026-06-17

### Added

- Added circle, capsule, and configurable rounded-rectangle shapes.
- Added content-driven multiline skeleton bars for SwiftUI and UIKit.
- Added all eight shimmer directions and shared gradient geometry.
- Added SwiftUI environment appearance overrides and UIKit per-activation appearance overrides.
- Added interactive SwiftUI and UIKit control panels covering loading, direction, shape, theme, duration, and band width.

### Fixed

- Restored UIKit label color independently of overlay storage.
- Kept single-line SwiftUI text skeletons at full content width.

## [0.1.0] - 2026-06-16

### Added

- Added the initial SkeletonCore, SkeletonSwiftUI, and SkeletonUIKit products.
- Added platform-neutral configuration, RGBA color values, and shared time-based shimmer phase.
- Added SwiftUI in-place skeleton modifiers and UIKit view overlays.
- Added UIKit label-line layout and the shared display-link clock.
- Added the initial SwiftUI and UIKit demo application.

[0.4.0]: https://github.com/ibabyblue/ISkeleton/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/ibabyblue/ISkeleton/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/ibabyblue/ISkeleton/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/ibabyblue/ISkeleton/releases/tag/0.1.0
