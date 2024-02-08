import Foundation

public struct HistoryData: Codable {
    public let series: Series
    public let context: PlayerContext?

    public init(series: Series, context: PlayerContext) {
        self.series = series
        self.context = context
    }
}
