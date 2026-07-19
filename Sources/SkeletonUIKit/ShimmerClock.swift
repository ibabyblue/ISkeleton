#if canImport(UIKit)
import UIKit
import SkeletonCore

/// A main-actor object that receives synchronized phases from ``ShimmerClock``.
@MainActor
protocol ShimmerDriven: AnyObject {
    /// Applies the normalized highlight-band phase for the current frame.
    ///
    /// - Parameter phase: The normalized position of the band's leading edge.
    func applyShimmerPhase(_ phase: CGFloat)
    /// The configuration whose duration and band width drive this object.
    var shimmerConfiguration: SkeletonConfiguration { get }
}

/// Forwards display-link ticks without allowing the link to retain the shared clock.
private final class ClockProxy: NSObject {
    /// The weak clock that receives frame callbacks.
    weak var clock: ShimmerClock?
    /// Forwards one frame or invalidates the display link after the clock is released.
    ///
    /// - Parameter link: The display link producing the frame callback.
    @MainActor @objc func tick(_ link: CADisplayLink) {
        if let clock { clock.onFrame() } else { link.invalidate() }
    }
}

/// Drives every live UIKit skeleton from one process-wide display link and phase.
@MainActor
final class ShimmerClock {
    /// The process-wide clock shared by all UIKit skeleton overlays.
    static let shared = ShimmerClock()

    /// Weak storage for registered phase consumers.
    private let driven = NSHashTable<AnyObject>.weakObjects()
    /// The display link retained only while at least one live consumer exists.
    private var displayLink: CADisplayLink?

    /// The number of registered consumers that remain alive, exposed for tests.
    var drivenCountForTesting: Int { driven.allObjects.count }

    /// Creates the singleton and observes foreground transitions that may suspend its link.
    private init() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleForeground),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    /// Registers a weak phase consumer and starts the clock when necessary.
    ///
    /// - Parameter object: The consumer to update on each frame.
    func register(_ object: ShimmerDriven) {
        driven.add(object)
        startIfNeeded()
    }

    /// Removes a phase consumer and stops the clock when no consumers remain.
    ///
    /// - Parameter object: The consumer to unregister.
    func unregister(_ object: ShimmerDriven) {
        driven.remove(object)
        stopIfIdle()
    }

    /// Creates and schedules the display link only when a live consumer needs frames.
    private func startIfNeeded() {
        guard displayLink == nil, driven.anyObject != nil else { return }
        let proxy = ClockProxy()
        proxy.clock = self
        let link = CADisplayLink(target: proxy, selector: #selector(ClockProxy.tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    /// Invalidates and releases the display link when weak consumer storage is empty.
    private func stopIfIdle() {
        guard driven.allObjects.isEmpty else { return }
        displayLink?.invalidate()
        displayLink = nil
    }

    /// Calculates one absolute-time phase and applies it to every live consumer.
    fileprivate func onFrame() {
        let now = Date().timeIntervalSinceReferenceDate
        let objects = driven.allObjects.compactMap { $0 as? ShimmerDriven }
        if objects.isEmpty { stopIfIdle(); return }
        for o in objects {
            let cfg = o.shimmerConfiguration
            let phase = ShimmerPhase.phase(at: now, duration: cfg.duration, bandWidth: cfg.bandWidth)
            o.applyShimmerPhase(phase)
        }
    }

    /// Recreates the display link after UIKit returns to the foreground.
    @objc private func handleForeground() {
        // Recreate a link that UIKit may have suspended while the app was inactive.
        displayLink?.invalidate()
        displayLink = nil
        startIfNeeded()
    }
}
#endif
