//
//  TokenRepository.swift
//
//  Перенесено из master (Anilibria/Classes/DataLayer/TokenRepository).
//

import DITranquillity
import Foundation
import Combine

public final class TokenRepositoryPart: DIPart {
    public static func load(container: DIContainer) {
        container.register(TokenRepositoryImp.init)
            .as(TokenRepository.self)
            .as(Clearable.self)
            .lifetime(.single)
    }
}

public protocol TokenRepository: Clearable {
    func set(token: String)
    func getToken() -> AnyPublisher<String?, Never>
}

final class TokenRepositoryImp: TokenRepository {
    private let key: String = "USER_TOKEN"
    private let storage: SecureStorage

    init(storage: SecureStorage) {
        self.storage = storage
    }

    private var buffered: String?

    func set(token: String) {
        do {
            try storage.save(key: key, item: token)
            buffered = token
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func getToken() -> AnyPublisher<String?, Never> {
        if buffered != nil {
            return Just(buffered).eraseToAnyPublisher()
        }
        return storage.get(key: key)
            .handleEvents(receiveOutput: { [weak self] in
                self?.buffered = $0
            })
            .eraseToAnyPublisher()
    }

    func clear() {
        buffered = nil
        do {
            try storage.remove(key: key)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}
