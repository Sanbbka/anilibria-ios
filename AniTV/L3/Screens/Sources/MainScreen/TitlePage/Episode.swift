//
//  Episode.swift
//  Screens
//
//  Created by Alexander Drovnyashin on 2/3/25.
//


import SwiftUI
import AVFoundation
import AVKit
import Common

struct Episode: Identifiable {
    let id = UUID()
    let metadata: Metadata
    let videoURL: URL?
    let number: String
    let itemPlaylist: PlaylistItem
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
                    VideoPlayerView(url: videoURL, metadata: episode.metadata, startPlay: false, skips: episode.itemPlaylist.skips)
                        .frame(width: imageSize.width, height: imageSize.height)
                        .hoverEffect(.highlight)
                }
                
                Text("\(episode.number)")
        }
        .buttonStyle(.borderless)
        .fullScreenCover(isPresented: $isVideoPlayerPresented) {
            if let videoURL = episode.videoURL {
                VideoPlayerView(url: videoURL, metadata: episode.metadata, startPlay: true, skips: episode.itemPlaylist.skips)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    let metadata: Metadata
    let startPlay: Bool
    let skips: Skips?
    
    class Coordinator: NSObject {
            var parent: VideoPlayerView
            var timeObserver: Any? // Token для удаления наблюдателя
            
            init(parent: VideoPlayerView) {
                self.parent = parent
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerItem = AVPlayerItem(url: url)
        playerItem.externalMetadata = metadata.createMetadataItems()
        
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.layer.cornerRadius = 12
        if startPlay {
            playerViewController.player?.play()
        }
        
        guard let skips = skips else {
            return playerViewController
        }
        
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                
                // Сохраняем token для последующего удаления
                context.coordinator.timeObserver = player.addPeriodicTimeObserver(
                    forInterval: interval,
                    queue: .main // Вызываем на главной очереди
                ) { [weak playerViewController] time in
                    // time - текущее время в формате CMTime
                    let currentTime = Int(time.seconds)
                    // Ваша логика для показа/скрытия кнопки
                    let shouldShowSkip = skips.canSkip(time: currentTime)
                    
                    guard shouldShowSkip,
                          let upperBound = skips.upperBound(time: currentTime) else {
                        playerViewController?.contextualActions = []
                        return
                    }
                    
                    print("Текущее время: \(currentTime), Показывать пропуск: \(shouldShowSkip)")
                    showSkip(playerViewController: playerViewController, time: upperBound)
                }
        
        return playerViewController
    }
    
    func showSkip(playerViewController: AVPlayerViewController?, time: Int) {
        guard playerViewController?.contextualActions.isEmpty ?? false else {
            return
        }
        playerViewController?.contextualActions = [
            .init(title: "Пропустить", handler: { [weak playerViewController] action in
                playerViewController?.player?.seek(to: CMTime(seconds: Double(time), preferredTimescale: 1))
            })
        ]
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
            // ✅ ВАЖНО: Удаляем наблюдателя при уничтожении
            if let timeObserver = coordinator.timeObserver {
                uiViewController.player?.removeTimeObserver(timeObserver)
            }
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
