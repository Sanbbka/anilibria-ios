import Foundation
import SwiftUI
import ComposableArchitecture
import DITranquillity
@preconcurrency import ServiceLayer
import Combine
import Components

@Reducer
class SeriesPage: Reducer {
    init(container: DIContainer) {
        self.container = container
        self.feedService = container.resolve()
    }
    
    @ObservableState
    struct State {
        var series: Series
    }
    enum Action {
        case start
        case loaded(Series)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .start:
                let code = state.series.code
                return .run { send in
                    var bag = Set<AnyCancellable>()
                    let result = try await withCheckedThrowingContinuation { continuation in
                        self.feedService.series(with: code)
                            .sink(onNext: { item in
                                continuation.resume(returning: item)
                            })
                            .store(in: &bag)
                    }
                    
                    await send(.loaded(result))
                }
            case .loaded(let series):
                state.series = series
            }
            
            return .none
        }
    }
    
    let container: DIContainer
    let feedService: FeedService
}

extension Series {
    var episodes: [Episode] {
        playlist.compactMap { Episode(videoURL: $0.video[$0.supportedQualities().first ?? .fullHd], number: $0.title) }
    }
    
    var moreSeasons: [(title: String, url: URL)] {
        desc?.extractLinks() ?? []
    }
    
    var descriptionTexts: String? {
        let texts = desc?.string.split(separator: "\n\n") ?? []
        return texts.first.map(String.init)
    }
}

public struct SeriesPageView: View {
    @Namespace var seriesPageView
    
    let store: StoreOf<SeriesPage>
    let container: DIContainer
    
    @FocusState var isFocused
    
    var episodes: [Episode] {
        store.series.episodes
    }
    
    var moreSeasons: [(title: String, url: URL)] {
        store.series.moreSeasons
    }
    
    var descriptionTexts: String? {
        store.series.descriptionTexts
    }
    
    public init(series: Series, container: DIContainer) {
        store = Store(initialState: SeriesPage.State(series: series), reducer: {
            SeriesPage(container: container)
        })
        self.container = container
    }
    
    public var body: some View {
        VStack {
            Group {
                ScrollView (.vertical, showsIndicators: false) {
                    VStack(spacing: 22) {
                        Button {} label: {
                            VStack {
                                ForEach(Array(store.series.names.enumerated()), id: \.offset) { index, text in
                                    if index == .zero {
                                        Text(text)
                                            .font(.headline)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        Text(text)
                                            .foregroundColor(.secondary)
                                            .font(.subheadline)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }.focusable()
                        }
                        EpisodesListView(episodes: episodes) { episode in
                            print("choose: ", episode)
                        }
                        if let string = descriptionTexts {
                            DescLabel(string: string)
                        }
                        if !moreSeasons.isEmpty {
                            Text("Еще сезоны:")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(moreSeasons, id: \.title) { season in
                                    HStack {
                                        BaseButton(string: season.title)
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                }.scrollTargetBehavior(.viewAligned)
            }
            .padding(22)
            .scrollClipDisabled()
            .scrollTargetLayout()
        }
        .onAppear {
            store.send(.start)
        }
        .focusScope(seriesPageView)
    }
}

extension NSAttributedString {
    func extractLinks() -> [(title: String, url: URL)] {
        let attributedString = self
        var links: [(title: String, url: URL)] = []
        
        let range = NSRange(location: 0, length: attributedString.length)
        
        attributedString.enumerateAttributes(in: range, options: []) { attributes, range, _ in
            if let url = attributes[.link] as? URL {
                let title = attributedString.attributedSubstring(from: range).string
                links.append((title: title, url: url))
            }
        }
        
        return links
    }
}
