import Foundation

/// 演示用的个人资料卡数据。
struct DemoProfile: Identifiable {
    let id = UUID()
    let name: String    // 单行
    let price: String   // 单行
    let bio: String     // 2–3 行，演示多行骨架
}

extension DemoProfile {
    /// 真实示例数据（bio 长度不一）。
    static let samples: [DemoProfile] = [
        DemoProfile(name: "亿人类的梦", price: "￥128.00",
                    bio: "热爱旅行与摄影，周末喜欢去山里露营，记录每一个值得纪念的瞬间。"),
        DemoProfile(name: "better me", price: "￥66.00",
                    bio: "健身三年，撸铁与跑步爱好者，目标是今年马拉松全程完赛。"),
        DemoProfile(name: "咕噜豆包儿", price: "￥888.88",
                    bio: "猫奴一枚，家里两只布偶。日常写代码、做手工、研究咖啡豆的烘焙曲线，生活节奏慢但很充实。")
    ]

    /// loading 时撑出尺寸/行数的代表性占位内容。
    static let placeholderName = "占位昵称占位"
    static let placeholderPrice = "￥00.00"
    static let placeholderBio = String(repeating: "占位文本占位文本", count: 6)

    /// loading 态展示的占位卡（id 稳定，避免 SwiftUI ForEach 身份抖动）。
    static let placeholderCards: [DemoProfile] = (0..<3).map { _ in
        DemoProfile(name: placeholderName, price: placeholderPrice, bio: placeholderBio)
    }
}

/// 模拟异步加载（demo 专用，不进库）。
@MainActor
enum DemoLoader {
    /// 约 1.5s 后返回示例数据。
    static func load() async -> [DemoProfile] {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        return DemoProfile.samples
    }
}
