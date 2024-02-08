import DITranquillity
import Foundation

public final class LinksRepositoryPart: DIPart {
    public static func load(container: DIContainer) {
        container.register(LinksRepositoryImp.init)
            .as(LinksRepository.self)
            .lifetime(.single)
    }
}

public protocol LinksRepository {
    func set(items: [LinkData])
    func getItems() -> [LinkData]
}

final class LinksRepositoryImp: LinksRepository {
    private let key: String = "LINKS_KEY"

    private var buffered: LinksHolder?

    func set(items: [LinkData]) {
        self.buffered = LinksHolder(date: Date(), items: items)
        UserDefaults.standard[key] = self.buffered
    }

    func getItems() -> [LinkData] {
        if let data = self.buffered, data.date?.isToday == true {
            return data.items
        }

        self.buffered = UserDefaults.standard[key] ?? LinksHolder(items: [])
        return self.buffered!.items
    }
}

private struct LinksHolder: Codable {
    var date: Date?
    var items: [LinkData]
}
