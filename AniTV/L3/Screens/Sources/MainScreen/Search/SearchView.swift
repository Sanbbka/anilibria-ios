//
//  SearchView.swift
//  Screens
//
//  Created by Alexander Drovnyashin on 6/3/25.
//

import Common
import SwiftUI
import Kingfisher
import Components
import ServiceLayer
import DITranquillity
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published
    var posters: [PosterModel] = []
    var series: [Series] = []
    
    var diContainer: DIContainer? {
        didSet {
            feedService = diContainer?.resolve()
        }
    }
    
    private var feedService: FeedService?
    private var cancellable = Set<AnyCancellable>()
    
    func loadData(searchTerm: String = "") {
        guard !searchTerm.isEmpty else {
            series = []
            return
        }
        feedService?.search(query: searchTerm).sink(receiveValue: { [weak self] series in
            self?.posters = series.compactMap { PosterModel(id: $0.id, title: $0.names.first ?? "", description: $0.desc?.string ?? "", posterUrl: $0.poster) }
            self?.series = series
        }).store(in: &cancellable)
    }
}

struct CardView: View {
    let poster: PosterModel
    let action: () -> Void
        
    var body: some View {
        Button(action: action) {
            KFImage(poster.posterUrl)
                .resizable()
                .aspectRatio(250 / 375, contentMode: .fit)
            
            Text(poster.title)
                .lineLimit(2, reservesSpace: true)
        }
    }
}

let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 40), count: 6)

public struct SearchView: View {
    @EnvironmentObject
    var dependencyContainer: DependencyContainer
    
    @State
    var searchTerm: String = ""
    
    @ObservedObject
    private var viewModel = SearchViewModel()
    
    @State
    private var poster: PosterModel?
        
    public var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns, spacing: 60) {
                ForEach(viewModel.posters) { poster in
                    CardView(poster: poster) {
                        self.poster = poster
                    }
                }
            }
            .buttonStyle(.borderless)
        }
        .scrollClipDisabled()
        .searchable(text: $searchTerm)
        .onAppear {
            viewModel.diContainer = dependencyContainer.container
        }.onChange(of: searchTerm) { oldValue, newValue in
            viewModel.loadData(searchTerm: searchTerm)
        }
        .fullScreenCover(item: $poster) { item in
            if let series = viewModel.series.first(where: { $0.id == item.id }) {
                ZStack {
                    Color.appBackground
                        .ignoresSafeArea()
                    SeriesPageView(series: series, container: dependencyContainer.container, isFullScreen: true)
                }
            }
        }
    }
    
    public init() {}
}
