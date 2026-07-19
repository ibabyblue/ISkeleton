# ISkeleton Example

This application is the runnable companion to ISkeleton's README and three DocC catalogs. It links the repository root as a local Swift package, so every scenario exercises the checked-out Core, SwiftUI, and UIKit implementations.

## Requirements

- Xcode 16.0 or newer
- XcodeGen when regenerating the project
- iOS 15 or newer simulator or device

The committed Xcode project opens without XcodeGen, and all Example tests run offline.

## Generate the project

`project.yml` is the source of truth for targets and the shared scheme. Regenerate after changing project structure:

```bash
xcodegen generate --spec Example/project.yml --project Example
```

Do not edit target membership or schemes only in the generated project.

## Run the labs

Open `Example/ISkeletonDemo.xcodeproj`, select the shared `ISkeletonDemo` scheme, choose an iOS destination, and run.

The application provides two tabs:

| Lab | What it demonstrates |
| --- | --- |
| SwiftUI | Environment appearance, nested overrides, geometric shapes, dynamic multiline bars, and image-alpha masks |
| UIKit | Global appearance, per-activation overrides, activation snapshots, TextKit line bars, shared-clock lifecycle, and bitmap image masks |

Both labs expose the same live configuration surface:

- all eight shimmer directions;
- circle, capsule, and rounded-rectangle shapes;
- default, dark, and tinted color presets;
- sweep duration and normalized band width;
- loading-to-content transitions;
- profile slots with circle, single-line, and multiline placeholders;
- a transparent Swift logo rendered through image alpha;
- a fixed local appearance override independent of the main panel.

## Build and test

From the repository root, build the Example with:

```bash
xcodebuild -quiet build \
  -project Example/ISkeletonDemo.xcodeproj \
  -scheme ISkeletonDemo \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO
```

The shared scheme includes `ISkeletonDemoUITests`, which verifies that the SwiftUI and UIKit labs and their loading controls are reachable:

```bash
xcodebuild -quiet test \
  -project Example/ISkeletonDemo.xcodeproj \
  -scheme ISkeletonDemo \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO
```

Choose another installed iPhone simulator when `iPhone 17 Pro` is unavailable.

## Continue with DocC

Use the Example for live integrations and the module catalogs for complete behavior and API detail:

- [SkeletonCore](../Sources/SkeletonCore/SkeletonCore.docc/SkeletonCore.md)
- [SkeletonSwiftUI](../Sources/SkeletonSwiftUI/SkeletonSwiftUI.docc/SkeletonSwiftUI.md)
- [SkeletonUIKit](../Sources/SkeletonUIKit/SkeletonUIKit.docc/SkeletonUIKit.md)
