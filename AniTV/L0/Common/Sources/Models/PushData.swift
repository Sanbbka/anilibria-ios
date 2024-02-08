import Foundation

public final class PushData: NSObject {
    public var link: URL?

    public init(_ values: [String : Any]) {
        super.init()
        self.link = (values["link"] <- AnyURLConverter())
    }
}
