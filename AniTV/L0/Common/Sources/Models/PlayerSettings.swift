import Foundation

public struct PlayerSettings: Codable {
    public var quality: VideoQuality = .fullHd

    public init() {}
}
