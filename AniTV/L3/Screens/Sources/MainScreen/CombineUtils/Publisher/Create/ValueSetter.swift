//
//  ValueSetter.swift
//  
//
//  Created by Churyanin NG on 02.06.2022.
//

import Foundation

/// Астрактный тип для установки значения
open class ValueSetter<Value> {
    public init() {}
    open func set(value: Value) {}
}
