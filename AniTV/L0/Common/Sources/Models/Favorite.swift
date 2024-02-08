import Foundation

public final class Favorite: NSObject, Decodable {
    public var rating: Int = 0
    public var added: Bool = false

    public init(from decoder: Decoder) throws {
        super.init()
        self.rating <- decoder["rating"]
		self.added <- decoder["added"]
    }
}
