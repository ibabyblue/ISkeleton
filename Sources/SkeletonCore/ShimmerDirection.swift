import CoreGraphics

/// A direction that defines normalized start and end points for a shimmer sweep.
public enum ShimmerDirection: Sendable, Equatable, CaseIterable {
    /// The four edge-to-edge sweep directions.
    ///
    /// - `leftToRight`: Moves horizontally from the leading edge to the trailing edge.
    /// - `rightToLeft`: Moves horizontally from the trailing edge to the leading edge.
    /// - `topToBottom`: Moves vertically from the top edge to the bottom edge.
    /// - `bottomToTop`: Moves vertically from the bottom edge to the top edge.
    case leftToRight, rightToLeft, topToBottom, bottomToTop
    /// The two top-originating diagonal sweep directions.
    ///
    /// - `topLeftToBottomRight`: Moves from the top-left corner to the bottom-right corner.
    /// - `topRightToBottomLeft`: Moves from the top-right corner to the bottom-left corner.
    case topLeftToBottomRight, topRightToBottomLeft
    /// The two bottom-originating diagonal sweep directions.
    ///
    /// - `bottomLeftToTopRight`: Moves from the bottom-left corner to the top-right corner.
    /// - `bottomRightToTopLeft`: Moves from the bottom-right corner to the top-left corner.
    case bottomLeftToTopRight, bottomRightToTopLeft

    /// The normalized point at which this direction's sweep axis begins.
    public var start: CGPoint {
        switch self {
        case .leftToRight:          return CGPoint(x: 0,   y: 0.5)
        case .rightToLeft:          return CGPoint(x: 1,   y: 0.5)
        case .topToBottom:          return CGPoint(x: 0.5, y: 0)
        case .bottomToTop:          return CGPoint(x: 0.5, y: 1)
        case .topLeftToBottomRight: return CGPoint(x: 0,   y: 0)
        case .topRightToBottomLeft: return CGPoint(x: 1,   y: 0)
        case .bottomLeftToTopRight: return CGPoint(x: 0,   y: 1)
        case .bottomRightToTopLeft: return CGPoint(x: 1,   y: 1)
        }
    }

    /// The normalized point at which this direction's sweep axis ends.
    public var end: CGPoint {
        switch self {
        case .leftToRight:          return CGPoint(x: 1,   y: 0.5)
        case .rightToLeft:          return CGPoint(x: 0,   y: 0.5)
        case .topToBottom:          return CGPoint(x: 0.5, y: 1)
        case .bottomToTop:          return CGPoint(x: 0.5, y: 0)
        case .topLeftToBottomRight: return CGPoint(x: 1,   y: 1)
        case .topRightToBottomLeft: return CGPoint(x: 0,   y: 1)
        case .bottomLeftToTopRight: return CGPoint(x: 1,   y: 0)
        case .bottomRightToTopLeft: return CGPoint(x: 0,   y: 0)
        }
    }

    /// Calculates the gradient endpoints for one shimmer frame along this direction's axis.
    ///
    /// For ``leftToRight``, the result is equivalent to `(phase, 0.5)` through
    /// `(phase + bandWidth, 0.5)`.
    ///
    /// - Parameters:
    ///   - phase: The normalized position of the highlight band's leading edge.
    ///   - bandWidth: The normalized distance between the gradient endpoints.
    /// - Returns: The normalized start and end points for the current frame.
    public func gradientPoints(phase: CGFloat, bandWidth: CGFloat) -> (start: CGPoint, end: CGPoint) {
        let s = start, e = end
        /// Interpolates a normalized position along the direction's sweep axis.
        ///
        /// - Parameter t: The normalized distance from the start point.
        /// - Returns: The point at that distance along the axis.
        func lerp(_ t: CGFloat) -> CGPoint {
            CGPoint(x: s.x + (e.x - s.x) * t, y: s.y + (e.y - s.y) * t)
        }
        return (lerp(phase), lerp(phase + bandWidth))
    }
}
