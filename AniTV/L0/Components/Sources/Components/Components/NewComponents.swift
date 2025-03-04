//
//  NewComponents.swift
//  Components
//
//  Created by Alexander Drovnyashin on 1/3/25.
//

import SwiftUI

// 1. Горизонтальная карточка с фокус-эффектом
struct FocusableCard: View {
    let title: String
    let image: String
    let episodes: String
    
    @FocusState var isFocused
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: image)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 400, height: 225)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.4), radius: 8, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.8), lineWidth: 2)
            )
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(episodes)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .focusable(true)
        .scaleEffect(1.05, anchor: .center)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// 2. Информационная панель сериала
struct MediaInfoPanel: View {
    let title: String
    let year: String
    let genres: [String]
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text(year)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            
            TagCloudView(tags: genres)
            
            Text(description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(6)
        }
        .padding()
        .background(Color(.systemGray))
        .cornerRadius(16)
    }
}

// 3. Секция с заголовком
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 24)
    }
}

// 4. Навигационная кнопка
struct NavButton: View {
    let icon: String
    let label: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(label)
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color(.systemGray))
        .cornerRadius(12)
        .focusable(true)
    }
}

// 5. Поисковая строка для TV
struct TVSearchField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search by name", text: $text)
                .foregroundColor(.white)
                .font(.title3)
        }
        .padding()
        .background(Color(.systemGray))
        .cornerRadius(12)
    }
}

// 6. Тэги для жанров
struct TagCloudView: View {
    let tags: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(20)
                }
            }
        }
    }
}
