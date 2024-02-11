import DITranquillity
import Foundation
import ServiceLayer
import DataLayer

public class AppFramework: DIFramework {
    public static func load(container: DIContainer) {
        container.append(part: SomePart.self)
        container.append(part: RepositoriesPart.self)
        container.append(part: ServicesPart.self)
    }
}

private class RepositoriesPart: DIPart {
    static let parts: [DIPart.Type] = [
        ConfigRepositoryPart.self,
        HistoryRepositoryPart.self,
        PlayerSettingsRepositoryPart.self,
        UserRepositoryPart.self,
        LinksRepositoryPart.self,
        BackendRepositoryPart.self
    ]

    static func load(container: DIContainer) {
        for part in self.parts {
            container.append(part: part)
        }

        container.register {
            ClearableManagerImp(items: many($0))
        }
        .as(ClearableManager.self)
        .lifetime(.single)
    }
}

private class ServicesPart: DIPart {
    static let parts: [DIPart.Type] = [
        AppConfigurationServicePart.self,
        PlayerServicePart.self,
        FavoriteServicePart.self,
        SessionServicePart.self,
        MenuServicePart.self,
        FeedServicePart.self,
        LinksServicePart.self,
        DownloadServicePart.self
    ]

    static func load(container: DIContainer) {
        for part in self.parts {
            container.append(part: part)
        }
    }
}
private class SomePart: DIPart {
    static func load(container: DIContainer) {
        container.register {
            BackendConfiguration(converter: JsonResponseConverter(),
                                 interceptor: nil,
                                 retrier: $0)
        }
        .lifetime(.single)

        container.register(MainRetrier.init)
            .injection(cycle: true, { $0.sessionService = $1 })
            .as(LoadRetrier.self)
            .lifetime(.single)
    }
}

final class MainRetrier: LoadRetrier {
    weak var sessionService: SessionService?

    func need(retry request: URLRequest, error: Error, retryNumber: Int, completion: @escaping RetryCompletion) {
        if case let .network(code) = error as? AppError, code == 401 {
            self.sessionService?.forceLogout()
        }
        completion(false) // don't retry
    }
}
