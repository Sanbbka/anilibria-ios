import Foundation

public enum OAuthSocial: String, Decodable {
    case vk
}

public struct SocialOAuthData: Decodable {
    public private(set) var key: OAuthSocial?
    public private(set) var title: String = ""
    public private(set) var socialUrl: URL?
    public private(set) var resultPattern: String = ""
    public private(set) var errorUrlPattern: String = ""

    public init(from decoder: Decoder) throws {
		self.key <- decoder["key"]
		self.title <- decoder["title"]
		self.socialUrl <- decoder["socialUrl"] <- URLConverter("")
		self.resultPattern <- decoder["resultPattern"]
		self.errorUrlPattern <- decoder["errorUrlPattern"]
    }
}
