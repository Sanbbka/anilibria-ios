//
//  BaseButton.swift
//  Components
//
//  Created by Alexander Drovnyashin on 5/3/25.
//

import SwiftUI

public struct BaseButton: View {
    var string: String
    var completion: (() -> Void)?
    public var body: some View {
        Button {
            completion?()
        } label: {
            Text(string)
                .font(.body.bold())
        }
    }
    
    public init(string: String, completion: (() -> Void)? = nil) {
        self.string = string
        self.completion = completion
    }
}
