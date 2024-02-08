import Foundation

public enum ResponseKey: String, Decodable {
    case success
    case authorized
    case unknown
}

public struct ServerResponse: Decodable {
    public private(set) var key: ResponseKey = .unknown
    public private(set) var message: String = ""
    public private(set) var error: AppError?

    public init(from decoder: Decoder) throws {
        self.key <- decoder["key"]
		self.message <- decoder["mes"]
		self.error <- decoder["err"] <- ErrorConverter()
    }
}
