public final class FilterData {
    public init(years: [String] = [], genres: [String] = []) {
        self.years = years
        self.genres = genres
    }
    
    public var years: [String] = []
    public var genres: [String] = []
    public let seasons: [TextWithTranslation] = [
        TextWithTranslation(original: "зима", translation: "L10n.Common.Seasons.winter"),
        TextWithTranslation(original: "весна", translation: "L10n.Common.Seasons.spring"),
        TextWithTranslation(original: "лето", translation: "L10n.Common.Seasons.summer"),
        TextWithTranslation(original: "осень", translation: "L10n.Common.Seasons.fall")
    ]
}
