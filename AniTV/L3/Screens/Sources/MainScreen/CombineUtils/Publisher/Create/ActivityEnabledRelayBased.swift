//
//  ActivityEnabledRelayBased.swift
//  
//
//  Created by Churyanin NG on 15.09.2022.
//  
//

import Combine

/// Проперти враппер, создает анонимную последовательность на основе CurrentValueSubject для хранения состояние загрузки
/// и отображения активити индикатора
/// [Тесты](x-source-tag://CombineUtils.ActivityEnabledRelayBasedTests)
/// - Tag: CombineUtils.ActivityEnabledRelayBased
@propertyWrapper
public class ActivityEnabledRelayBased: ValueSetter<Bool> {

    let subject = CurrentValueSubject<Int, Never>(0)
    public var wrappedValue: AnyPublisher<Bool, Never> {
        subject.map { $0 > 0 }.removeDuplicates().eraseToAnyPublisher()
    }

    public var value: Bool {
        subject.value > 0
    }

    override public func set(value: Bool) {
        let newValue = max(subject.value + (value ? 1 : -1), 0)
        subject.send(newValue)
    }
}
