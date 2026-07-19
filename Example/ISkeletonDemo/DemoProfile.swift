import Foundation

/// A stable profile-card value used by both framework labs.
struct DemoProfile: Identifiable {
    /// The stable identity used by SwiftUI collections.
    let id = UUID()
    /// The single-line display name.
    let name: String
    /// The single-line formatted price.
    let price: String
    /// The longer biography used to demonstrate multiline skeleton bars.
    let bio: String
}

/// Provides loaded and representative loading content for profile examples.
extension DemoProfile {
    /// Loaded sample profiles with biographies of varying lengths.
    static let samples: [DemoProfile] = [
        DemoProfile(name: "亿人类的梦", price: "￥128.00",
                    bio: "热爱旅行与摄影，周末喜欢去山里露营，记录每一个值得纪念的瞬间。"),
        DemoProfile(name: "better me", price: "￥66.00",
                    bio: "健身三年，撸铁与跑步爱好者，目标是今年马拉松全程完赛。"),
        DemoProfile(name: "咕噜豆包儿", price: "￥888.88",
                    bio: "猫奴一枚，家里两只布偶。日常写代码、做手工、研究咖啡豆的烘焙曲线，生活节奏慢但很充实。")
    ]

    /// Representative text that reserves a typical name width while loading.
    static let placeholderName = "占位昵称占位"
    /// Representative text that reserves a typical price width while loading.
    static let placeholderPrice = "￥00.00"
    /// Representative text that reserves a typical multiline biography footprint.
    static let placeholderBio = "热爱旅行与摄影，周末喜欢去山里露营，记录每一个值得纪念的瞬间。"

    /// Three stable placeholder cards that avoid collection identity changes while loading.
    static let placeholderCards: [DemoProfile] = (0..<3).map { _ in
        DemoProfile(name: placeholderName, price: placeholderPrice, bio: placeholderBio)
    }
}

/// Simulates asynchronous loading for the Example without entering package targets.
@MainActor
enum DemoLoader {
    /// Returns the sample profiles after approximately 1.5 seconds.
    ///
    /// - Returns: The loaded profile values.
    static func load() async -> [DemoProfile] {
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        return DemoProfile.samples
    }
}
