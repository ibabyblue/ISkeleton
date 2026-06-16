import CoreGraphics

/// 平台无关的颜色值（各分量 0...1）。各平台 target 提供到原生颜色的转换。
public struct SkeletonRGBA: Equatable, Sendable {
    public var r: Double
    public var g: Double
    public var b: Double
    public var a: Double

    public init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}
