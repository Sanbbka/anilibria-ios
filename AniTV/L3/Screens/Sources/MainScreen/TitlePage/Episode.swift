//
//  Episode.swift
//  Screens
//
//  Created by Alexander Drovnyashin on 2/3/25.
//


import SwiftUI
import AVFoundation

struct Episode: Identifiable {
    let id = UUID()
    let metadata: Metadata
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
    @State private var isVideoPlayerPresented = false
    
    var body: some View {
        Button {
            isVideoPlayerPresented = true
        } label: {
                if let videoURL = episode.videoURL {
                    VideoPlayerView(url: videoURL, metadata: episode.metadata)
                        .frame(width: imageSize.width, height: imageSize.height)
                        .hoverEffect(.highlight)
                }
                
                Text("\(episode.number)")
        }
        .buttonStyle(.borderless)
        .fullScreenCover(isPresented: $isVideoPlayerPresented) {
            if let videoURL = episode.videoURL {
                VideoPlayerView(url: videoURL, metadata: episode.metadata)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

import AVKit

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    let metadata: Metadata

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerItem = AVPlayerItem(url: url)
        playerItem.externalMetadata = metadata.createMetadataItems()
        
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.layer.cornerRadius = 12
        
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Здесь можно обновить пользовательский интерфейс при необходимости
    }
}

struct Metadata {
    let title: String?
    let subtitle: String?
    let image: String?
    let description: String?
    let rating: String?
    let genre: String?
    
    func createMetadataItems() -> [AVMetadataItem] {
        let mapping: [AVMetadataIdentifier: Any] = [
            .commonIdentifierTitle: title ?? "",
            .iTunesMetadataTrackSubTitle: subtitle ?? "",
//            .commonIdentifierArtwork: UIImage(named: image)?.pngData() as Any,
            .commonIdentifierDescription: description ?? "",
            .iTunesMetadataContentRating: rating ?? "",
            .quickTimeMetadataGenre: genre ?? ""
        ]
        return mapping.compactMap { createMetadataItem(for:$0, value:$1) }
    }


    private func createMetadataItem(for identifier: AVMetadataIdentifier,
                                    value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        // Specify "und" to indicate an undefined language.
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }
}
