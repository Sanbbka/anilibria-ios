//
//  TextWithTranslation.swift
//  Anilibria
//
//  Created by Ivan Morozov on 30.11.2023.
//  Copyright © 2023 Иван Морозов. All rights reserved.
//

import Foundation

public struct TextWithTranslation {
    public let original: String
    public var displayValue: String {
        translation()
    }
    
    private var translation: () -> String
    
    public init(original: String, translation: @escaping @autoclosure () -> String) {
        self.original = original
        self.translation = translation
    }
}
