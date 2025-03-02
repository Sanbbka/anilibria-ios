//
//  PassthroughRelayBased.swift
//  
//
//  Created by Churyanin NG on 03.06.2022.
//

import Combine
import Foundation

/// Проперти враппер, создает анонимную последовательность на основе PassthroughRelayBased, работает на главном потоке
/// также предоставляет доступ на установку нового значения
@propertyWrapper
public class PassthroughRelayBased<Output>: ValueSetter<Output> {

    let subject = PassthroughSubject<Output, Never>()
    public let wrappedValue: AnyPublisher<Output, Never>

    override public init() {
        self.wrappedValue = subject.eraseToAnyPublisher()
    }

    override public func set(value: Output) {
        subject.send(value)
    }
}
