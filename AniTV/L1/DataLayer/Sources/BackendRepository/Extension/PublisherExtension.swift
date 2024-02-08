//
//  PublisherExtension.swift
//  Anilibria
//
//  Created by Ivan Morozov on 05.11.2022.
//  Copyright © 2022 Иван Морозов. All rights reserved.
//

import Combine

public extension Publisher {
    static func just<Value>(_ value: Value) -> AnyPublisher<Value, Failure> {
        Just(value).setFailureType(to: Failure.self).eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        Fail(outputType: Output.self, failure: error).eraseToAnyPublisher()
    }

    static func empty(completeImmediately: Bool = false) -> AnyPublisher<Output, Failure> {
        Empty(completeImmediately: completeImmediately, outputType: Output.self, failureType: Failure.self).eraseToAnyPublisher()
    }
}

public extension Publisher where Failure == Error {
    func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }
}

public extension Publisher {
    func afterDone(_ action: @escaping ActionFunc) -> Publishers.HandleEvents<Self> {
        return self.handleEvents(receiveCompletion: { _ in action()})
    }

    func `do`(onNext: ((Output) -> Void)?) -> Publishers.HandleEvents<Self> {
        return self.handleEvents(receiveOutput: { value in onNext?(value) })
    }

    func sink(onNext: ((Output) -> Void)? = nil, onError: ((Error) -> Void)? = nil) -> AnyCancellable {
        self.sink { completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                onError?(error)
            }
        } receiveValue: { value in
            onNext?(value)
        }
    }
}
