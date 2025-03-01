//
//  Colors.swift
//  Components
//
//  Created by Alexander Drovnyashin on 2/3/25.
//

import UIKit
import SwiftUICore

public extension Color {
    static let appText = Color(red: 0.98, green: 0.96, blue: 0.92)
    static let appBackground = Color(red: 0.18, green: 0.18, blue: 0.18)
    static let textDesctiption = Color(red: 0.96, green: 0.96, blue: 0.96)
    static let systemGrayDarker = Color(UIColor.systemGray).opacity(0.25)
}

public extension Color {
    static let tvBackground = Color(.systemGray)
    static let cardHighlight = Color.blue.opacity(0.3)
}
