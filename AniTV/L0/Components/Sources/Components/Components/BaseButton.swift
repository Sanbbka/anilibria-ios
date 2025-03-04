//
//  BaseButton.swift
//  Components
//
//  Created by Alexander Drovnyashin on 5/3/25.
//

import SwiftUI

public struct BaseButton: View {
    var string: String
    public var body: some View {
        Button {} label: {
            Text(string)
                .font(.body.bold())
        }
    }
    
    public init(string: String) {
        self.string = string
    }
}
