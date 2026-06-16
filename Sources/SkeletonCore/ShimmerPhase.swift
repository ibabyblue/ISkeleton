import CoreGraphics
import Foundation

/// 扫光相位：把绝对时间映射成高光带前缘的归一化位置。
/// band 区间为 [phase, phase + bandWidth]；phase 从 -bandWidth（全在左侧外）线性走到 1（全在右侧外），
/// 按 duration 无缝循环。两平台用同一 `Date().timeIntervalSinceReferenceDate` 代入 → 全局同相位。
public enum ShimmerPhase {
    public static func phase(at time: TimeInterval,
                             duration: TimeInterval,
                             bandWidth: CGFloat) -> CGFloat {
        guard duration > 0 else { return -bandWidth }
        let m = time.truncatingRemainder(dividingBy: duration)
        let t = CGFloat((m < 0 ? m + duration : m) / duration)   // 0..<1
        return -bandWidth + t * (1 + bandWidth)
    }
}
