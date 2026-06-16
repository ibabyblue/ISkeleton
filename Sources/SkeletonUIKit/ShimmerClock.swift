#if canImport(UIKit)
import UIKit
import SkeletonCore

/// 被 ShimmerClock 每帧驱动的对象。
@MainActor
protocol ShimmerDriven: AnyObject {
    /// 应用本帧扫光相位（high-light band 前缘的归一化位置）。
    func applyShimmerPhase(_ phase: CGFloat)
    /// 当前生效的外观（用于读取 duration/bandWidth）。
    var shimmerConfiguration: SkeletonConfiguration { get }
}

/// CADisplayLink 弱引用代理，避免 link 强引用 clock。
private final class ClockProxy: NSObject {
    weak var clock: ShimmerClock?
    @MainActor @objc func tick(_ link: CADisplayLink) {
        if let clock { clock.onFrame() } else { link.invalidate() }
    }
}

/// 进程内共享的扫光时钟：一条 CADisplayLink 以同一相位驱动所有激活的 overlay ⇒ 全局同相位。
@MainActor
final class ShimmerClock {
    static let shared = ShimmerClock()

    private let driven = NSHashTable<AnyObject>.weakObjects()
    private var displayLink: CADisplayLink?

    private init() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleForeground),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    func register(_ object: ShimmerDriven) {
        driven.add(object)
        startIfNeeded()
    }

    func unregister(_ object: ShimmerDriven) {
        driven.remove(object)
        stopIfIdle()
    }

    private func startIfNeeded() {
        guard displayLink == nil, driven.anyObject != nil else { return }
        let proxy = ClockProxy()
        proxy.clock = self
        let link = CADisplayLink(target: proxy, selector: #selector(ClockProxy.tick(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopIfIdle() {
        guard driven.allObjects.isEmpty else { return }
        displayLink?.invalidate()
        displayLink = nil
    }

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

    @objc private func handleForeground() {
        // 回前台时 link 可能被系统暂停；重启以恢复。
        displayLink?.invalidate()
        displayLink = nil
        startIfNeeded()
    }
}
#endif
