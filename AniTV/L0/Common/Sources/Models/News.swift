import Foundation

public final class News: NSObject, Decodable {
    public var id: Int = 0
    public var title: String = ""
    public var image: URL?
    public var vidUrl: URL?
    public var views: Int = 0
    public var comments: Int = 0
    public var date: Date?

    public init(from decoder: Decoder) throws {
        super.init()
		self.id <- decoder["id"]
		self.title <- decoder["title"] <- SpecialCharactersConverter()
        self.image <- decoder["image"] <- URLConverter(Configuration.imageServer)
		self.vidUrl <- decoder["vid"] <- YouTubeConverter()
		self.views <- decoder["views"]
		self.comments <- decoder["comments"]
		self.date <- decoder["timestamp"] <- DateConverter()
    }
}
