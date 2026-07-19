import CoreGraphics
import Foundation

/// Converts absolute time into the normalized leading-edge position of a shimmer band.
///
/// The band spans `phase...(phase + bandWidth)`. A phase advances from
/// `-bandWidth` to `1` over one duration and then repeats. Supplying the same
/// reference time keeps SwiftUI and UIKit skeletons in phase.
public enum ShimmerPhase {
    /// Calculates the shimmer phase for an absolute time.
    ///
    /// - Parameters:
    ///   - time: An absolute time interval, normally measured from the Foundation reference date.
    ///   - duration: The duration of one complete sweep, in seconds.
    ///   - bandWidth: The normalized width of the highlight band.
    /// - Returns: The normalized leading-edge position, or `-bandWidth` when `duration` is not positive.
    public static func phase(at time: TimeInterval,
                             duration: TimeInterval,
                             bandWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return -bandWidth }
        let m = time.truncatingRemainder(dividingBy: duration)
        let t = CGFloat((m < 0 ? m + duration : m) / duration)   // 0..<1
        return -bandWidth + t * (1 + bandWidth)
    }
}
