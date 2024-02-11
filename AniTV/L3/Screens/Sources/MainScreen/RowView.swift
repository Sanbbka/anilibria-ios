//
//  File.swift
//  
//
//  Created by Alexander Drovnyashin on 11/2/24.
//

import Foundation
import SwiftUI
import Kingfisher

struct PosterView: View {
    struct PosterModel {
        let title: String
        let posterUrl: URL?
    }
    
    let poster: PosterModel
    @FocusState var isFocused
    
    var body: some View {
        Button(
            action: { },
            label: {
                VStack(spacing: 4) {
                    KFImage(poster.posterUrl!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 400, height: 225)
                        .clipped()
                        .shadow(radius: 18, x: 0, y: isFocused ? 50 : 0)
                    
                    Text(poster.title)
                        .foregroundColor(isFocused ? .red : .black)
                    
                }
            }
        )
        .focused($isFocused)
        .buttonStyle(PressHandlingStyle())
        .scaleEffect(isFocused ? 1.2 : 1)
        .animation(.easeOut(duration: isFocused ? 0.12 : 0.35), value: isFocused)
    }
}

// We use this button style to handle `isPressed` state of the component.
struct PressHandlingStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? (1 / 1.15) : 1)
    }
}
