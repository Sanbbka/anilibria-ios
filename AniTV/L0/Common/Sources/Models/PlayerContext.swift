import Foundation

public struct PlayerContext: Codable {
    public var quality: VideoQuality = .fullHd
    public var number: Int = 0
    public var time: Double = 0

    public init(quality: VideoQuality, number: Int, time: Double) {
        self.quality = quality
        self.number = number
        self.time = time
    }
}
