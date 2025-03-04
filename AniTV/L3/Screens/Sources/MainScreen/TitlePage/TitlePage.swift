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

public struct SeriesPageView: View {
    @Namespace var seriesPageView
    
    let store: StoreOf<SeriesPage>
    let container: DIContainer
    
    @FocusState var isFocused
    
    var episodes: [Episode] {
        store.series.playlist.compactMap { Episode(videoURL: $0.video.first?.value, number: $0.title) }
    }
    
    var moreSeasons: [(title: String, url: URL)] {
        store.series.desc?.extractLinks() ?? []
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
                CardSection {
                    Group {
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
                ScrollView (.vertical, showsIndicators: false) {
                    EpisodesListView(episodes: episodes)
                    let texts = store.series.desc?.string.split(separator: "\n\n") ?? []
                    
                    if let string = texts.first {
                        CardSection {
                            Text(string)
                                .foregroundColor(.primary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    if !moreSeasons.isEmpty {
                        Text("Еще сезоны:")
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(22)
                            .background(Color.primary)
                            .foregroundColor(.cyan)
                            .scaleEffect(isFocused ? 1 : 0.98)
                            .focused($isFocused)
                            .focusable()
                        CardSection(focusable: false) {
                            Text("Еще сезоны:")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(moreSeasons, id: \.title) { season in
                                Text(season.title)
                                    .font(.headline)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(22)
                                    .background(Color.primary)
                                    .foregroundColor(.cyan)
                                    .scaleEffect(isFocused ? 1 : 0.98)
                                    .focused($isFocused)
                                    .focusable()
                            }
                        }
                    }
                }.scrollTargetBehavior(.viewAligned)
            }.padding(22)
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
