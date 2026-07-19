import CoreGraphics

/// Converts a text footprint and line height into platform-neutral skeleton bar geometry.
///
/// Framework integrations supply the resolved line height for their current font.
public enum SkeletonLineMetrics {
    /// Estimates the number of text lines in a footprint, rounded to the nearest whole line.
    ///
    /// - Parameters:
    ///   - height: The total text footprint height, in points.
    ///   - lineHeight: The resolved height of one line, in points.
    /// - Returns: At least one line. Invalid or nonpositive inputs also return `1`.
    public static func lineCount(height: CGFloat, lineHeight: CGFloat) -> Int {
        guard lineHeight > 0, height > 0 else { return 1 }
        return max(1, Int((height / lineHeight).rounded()))
    }

    /// Calculates the visible bar height within one line box.
    ///
    /// - Parameters:
    ///   - lineHeight: The resolved height of one line, in points.
    ///   - ratio: The portion of the line height occupied by the bar. The default is `0.7`.
    /// - Returns: A nonnegative bar height in points.
    public static func barHeight(lineHeight: CGFloat, ratio: CGFloat = 0.7) -> CGFloat {
        max(0, lineHeight * ratio)
    }
}
