import Foundation

public final class TitleItem: NSObject {
    public let localizedTitle: () -> String

    public init(_ title: @escaping @autoclosure () -> String) {
        self.localizedTitle = title
    }
}

public final class Schedule: NSObject, Decodable {
    public var day: WeekDay?
    public var items: [Series] = []
    public var title: TitleItem {
        TitleItem({ [weak self] in self?.day?.name ?? "" }())
    }

    public init(from decoder: Decoder) throws {
        super.init()
		self.day <- decoder["day"]
		self.items <- decoder["items"]
    }
}
