//
//  File.swift
//  
//
//  Created by Alexander Drovnyashin on 18/2/24.
//

import SwiftUI
import Kingfisher

public struct PosterModel: Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let description: String
    public let posterUrl: URL?
    
    public init(
        id: Int,
        title: String,
        description: String,
        posterUrl: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.posterUrl = posterUrl
    }
}

// We use this button style to handle `isPressed` state of the component.
struct PressHandlingStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? (1 / 1.15) : 1)
    }
}
