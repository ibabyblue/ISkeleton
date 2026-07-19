import CoreGraphics

/// A platform-neutral RGBA color whose components are expressed in `0...1`.
public struct SkeletonRGBA: Equatable, Sendable {
    /// The red component in `0...1`.
    public var r: Double
    /// The green component in `0...1`.
    public var g: Double
    /// The blue component in `0...1`.
    public var b: Double
    /// The alpha component in `0...1`.
    public var a: Double

    /// Creates a platform-neutral color value.
    ///
    /// - Parameters:
    ///   - r: The red component in `0...1`.
    ///   - g: The green component in `0...1`.
    ///   - b: The blue component in `0...1`.
    ///   - a: The alpha component in `0...1`. The default is `1`.
    public init(r: Double, g: Double, b: Double, a: Double = 1) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}
