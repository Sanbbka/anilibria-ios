import Foundation

public final class BlockInfo: NSObject, Decodable {
    public var isBlocked: Bool = false
    public var reason: String = ""

    public init(from decoder: Decoder) throws {
        super.init()
        self.isBlocked <- decoder["blocked"]
		self.reason <- decoder["reason"]
    }
}
