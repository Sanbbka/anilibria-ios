//
//  Episode.swift
//  Screens
//
//  Created by Alexander Drovnyashin on 2/3/25.
//


import SwiftUI

struct Episode: Identifiable {
    let id = UUID()
    let videoURL: URL?
    let number: String
}

struct EpisodesListView: View {
    let episodes: [Episode]
    
    // Размеры для TVOS
    private let imageSize = CGSize(width: 500, height: 300)
    private let cellSpacing: CGFloat = 40
    private let focusedScale: CGFloat = 1.08
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: cellSpacing) {
                ForEach(episodes) { episode in
                    EpisodeCell(episode: episode, 
                              imageSize: imageSize,
                              focusedScale: focusedScale)
                }
            }
            .padding(60)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
    }
}

struct EpisodeCell: View {
    let episode: Episode
    let imageSize: CGSize
    let focusedScale: CGFloat
    
    @FocusState private var isFocused
    @Namespace private var namespace
    
    var body: some View {
        VStack(spacing: 20) {
            if let videoURL = episode.videoURL {
                VideoPlayerView(url: videoURL)
                    .frame(width: imageSize.width, height: imageSize.height)
                    .scaleEffect(isFocused ? focusedScale : 1.0)
                    .clipped()
                    .cornerRadius(12)
            }
            
            Text("\(episode.number)")
                .font(.system(size: 36, weight: .medium))
                .foregroundColor(.white)
                .scaleEffect(isFocused ? 1.05 : 1.0)
                .opacity(isFocused ? 1.0 : 0.8)
                .multilineTextAlignment(.leading)
        }
        .focused($isFocused)
        .buttonStyle(.card)
        .frame(width: imageSize.width)
        .padding(.vertical, 0)
        .shadow(color: .black.opacity(isFocused ? 0.6 : 0.3),
                radius: isFocused ? 24 : 8,
                x: 0,
                y: isFocused ? 16 : 8)
        .animation(.interactiveSpring(response: 0.3,
                                      dampingFraction: 0.6),
                   value: isFocused)
        .scaleEffect(isFocused ? 1.1 : 1.0)
    }
}

import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Здесь можно обновить пользовательский интерфейс при необходимости
    }
}
