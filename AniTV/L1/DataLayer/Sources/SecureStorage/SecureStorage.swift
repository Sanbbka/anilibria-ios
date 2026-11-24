//
//  SecureStorage.swift
//
//  Перенесено из master (Anilibria/Classes/DataLayer/SecureStorage.swift),
//  адаптировано под tvOS: вместо UIApplication.protectedData используется
//  kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly.
//

import DITranquillity
import Combine
import Foundation
import Security

public protocol SecureStorage {
    func save<T: Codable>(key: String, item: T) throws
    func get<T: Codable>(key: String) -> AnyPublisher<T?, Never>
    func remove(key: String) throws
}

public final class SecureStoragePart: DIPart {
    public static func load(container: DIContainer) {
        container.register(KeychainManager.init)
            .as(SecureStorage.self)
            .lifetime(.single)
    }
}

final class KeychainManager: SecureStorage {
    enum KeychainError: Error {
        case unhandledError(status: OSStatus)
    }

    func save<T: Codable>(key: String, item: T) throws {
        try? remove(key: key)
        let data = try JSONEncoder().encode(item)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.unhandledError(status: status)
        }
    }

    private func searchQuery(for key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
    }

    func get<T: Codable>(key: String) -> AnyPublisher<T?, Never> {
        Deferred { () -> AnyPublisher<T?, Never> in
            Just(self.getValue(key: key))
                .setFailureType(to: Never.self)
                .eraseToAnyPublisher()
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    private func getValue<T: Codable>(key: String) -> T? {
        var query = searchQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess, let data = item as? Data {
            return try? JSONDecoder().decode(T.self, from: data)
        }
        return nil
    }

    func remove(key: String) throws {
        let query = searchQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.unhandledError(status: status)
        }
    }
}
