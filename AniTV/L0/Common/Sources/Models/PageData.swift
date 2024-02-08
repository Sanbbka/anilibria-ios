import Foundation

public final class PageData<T: Decodable>: NSObject, Decodable {
    public var items: [T] = []
    public var pagination: PaginationData?

    public init(from decoder: Decoder) throws {
        super.init()
		self.items <- decoder["items"]
		self.pagination <- decoder["pagination"]
    }
}

public final class PaginationData: NSObject, Decodable {
    public var page: Int = 0
    public var perPage: Int = 0
    public var allPages: Int = 0
    public var allItems: Int = 0

    public init(from decoder: Decoder) throws {
        super.init()
		self.page <- decoder["page"]
		self.perPage <- decoder["perPage"]
		self.allPages <- decoder["allPages"]
		self.allItems <- decoder["allItems"]
    }
}
