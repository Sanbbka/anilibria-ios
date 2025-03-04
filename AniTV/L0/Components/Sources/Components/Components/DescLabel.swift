//
//  DescLabel.swift
//  Components
//
//  Created by Alexander Drovnyashin on 5/3/25.
//

import SwiftUI

public struct DescLabel: View {
    var string: String
    public var body: some View {
        Button {} label: {
            Text(string)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
        }
        .buttonStyle(.plain)
    }
    
    public init(string: String) {
        self.string = string
    }
}
