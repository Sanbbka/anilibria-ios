//
//  Publisher+CollectValues.swift
//  CombineUtils
//
//  Created by Denis Tretyakov on 30.11.2023.
//

import Combine
import Foundation

extension Publisher {
    /// Расширение издателя для получения обновлённых данных или
    /// сигнала о том, что данные обновлены
    ///
    /// Может применяться ко всем типам издателей, обрабатывает ошибки
    /// - Parameter count: Буферизует максимальное количество элементов
    /// - Returns: Тип значений, опубликованных этим издателем
    ///
    @discardableResult
    public func collectValues(_ count: Int = 1) async throws -> [Output] {
        var cancellables: AnyCancellable?
        defer { cancellables?.cancel() }
        return try await withCheckedThrowingContinuation { continuation in
            cancellables = Publishers
                .CollectByCount(upstream: self, count: count)
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        case .finished:
                            break
                        }
                    },
                    receiveValue: { value in
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}

extension Publisher where Failure == Never {
    /// Расширение паблишера для получения обновлённых данных или
    /// сигнала о том, что данные обновлены.
    ///
    /// Применяется к издателям без обработки ошибок (`Never`)
    /// - Parameter count: Буферизует максимальное количество элементов
    /// - Returns: Тип значений, опубликованных этим издателем
    ///
    @discardableResult
    public func collectValues(_ count: Int = 1) async -> [Output] {
        var cancellables: AnyCancellable?
        defer { cancellables?.cancel() }
        return await withCheckedContinuation { continuation in
            cancellables = Publishers
                .CollectByCount(upstream: self, count: count)
                .sink { continuation.resume(returning: $0) }
        }
    }
}
