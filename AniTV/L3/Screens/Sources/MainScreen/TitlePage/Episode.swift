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
    let completion: (Episode) -> Void
    
    private let imageSize = CGSize(width: 400, height: 240)
    private let cellSpacing: CGFloat = 40
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: cellSpacing) {
                ForEach(episodes) { episode in
                    EpisodeCell(
                        episode: episode,
                        imageSize: imageSize
                    ).onTapGesture {
                        completion(episode)
                    }
                }
            }
            .padding(20)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
    }
}

struct EpisodeCell: View {
    let episode: Episode
    let imageSize: CGSize
    
    var body: some View {
        Button {} label: {
            VStack(spacing: 20) {
                if let videoURL = episode.videoURL {
                    VideoPlayerView(url: videoURL)
                        .frame(width: imageSize.width, height: imageSize.height)
                }
                
                Text("\(episode.number)")
            }
        }
    }
}

import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.layer.cornerRadius = 12
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Здесь можно обновить пользовательский интерфейс при необходимости
    }
}
