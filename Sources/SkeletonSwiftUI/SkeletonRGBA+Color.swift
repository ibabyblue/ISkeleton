import SwiftUI
import SkeletonCore

/// Adds SwiftUI color conversion to platform-neutral skeleton colors.
extension SkeletonRGBA {
    /// The equivalent sRGB SwiftUI color.
    var color: Color {
        Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
