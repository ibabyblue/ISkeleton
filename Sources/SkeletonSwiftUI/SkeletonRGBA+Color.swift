import SwiftUI
import SkeletonCore

extension SkeletonRGBA {
    /// 转 SwiftUI Color。
    var color: Color {
        Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
