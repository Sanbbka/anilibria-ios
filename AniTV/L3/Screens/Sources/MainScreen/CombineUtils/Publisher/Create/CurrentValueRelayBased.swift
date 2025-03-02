//
//  CurrentValueRelayBased.swift
//  
//
//  Created by Churyanin NG on 03.06.2022.
//

import Combine
import Foundation

/// Проперти враппер, создает анонимную последовательность на основе CurrentValueSubject, работает на главном потоке
/// также предоставляет доступ на установку нового значения
@propertyWrapper
public class CurrentValueRelayBased<Output>: ValueSetter<Output> {

    let subject: CurrentValueSubject<Output, Never>
    public let wrappedValue: AnyPublisher<Output, Never>

    public var didSetValue: ((Output) -> Void)?

    public var value: Output {
        subject.value
    }

    public init(_ value: Output) {
        self.subject = .init(value)
        self.wrappedValue = subject.eraseToAnyPublisher()
    }

    override public func set(value: Output) {
        subject.send(value)
        didSetValue?(value)
    }
}
