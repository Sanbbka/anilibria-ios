//
//  BookCardView.swift
//  Components
//
//  Created by Alexander Drovnyashin on 1/3/25.
//


import SwiftUI
import Kingfisher

public struct BookCardView: View {
    let poster: PosterModel
    let action: () -> Void
    
    @FocusState var isFocused

    public var body: some View {
        Button(
            action: action,
            label: {
                HStack(spacing: 12) {
                    KFImage(poster.posterUrl)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: isFocused ? .black : .clear, radius: 15, x: 10, y: 0)
                                            
                    VStack(spacing: 12) {
                        Text(poster.title)
                            .font(.system(size: 30, weight: .bold)) // Увеличенный размер шрифта для TV
                            .foregroundColor(.primary)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .shadow(color: isFocused ? .black : .clear, radius: 15, x: 0, y: 10)
                        
                        // Описание книги
                        Text(poster.description)
                            .font(.system(size: 23)) // Увеличенный размер шрифта для TV
                            .foregroundColor(.textDesctiption)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        Spacer()
                    }.padding(12)
                }
            }
        )
        .focused($isFocused)
        .buttonStyle(PressHandlingStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.systemGrayDarker)
                
        )
        .padding(12)
        .frame(height: 450)
        .scaleEffect(isFocused ? 1 : 0.97)
        .animation(.easeOut(duration: isFocused ? 0.12 : 0.35), value: isFocused)
        .clipped()
        
    }
}
