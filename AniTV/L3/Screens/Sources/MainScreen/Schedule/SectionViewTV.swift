//
//  File.swift
//  
//
//  Created by Alexander Drovnyashin on 11/2/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import DITranquillity
@preconcurrency import ServiceLayer
import Combine
import Components

@Reducer
public struct SectionTVReducer {
    @ObservableState
    public struct State: Equatable {
        public init(nextPage: Int = 0, series: [Series] = [Series]()) {
            self.nextPage = nextPage
            self.series = series
        }
        
        public var nextPage = 0
        public var series = [Series]()
        public var loading = false
        public var selectedSeries: Series?
    }

    public enum Action: Sendable {
        case start
        case loaded([Series]) // поправить сендабл
        case error
        case select(PosterModel)
        case selectSeries(Series)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .start:
                let nextPage = state.nextPage
                state.loading = true
                return .run { send in
                    var bag = Set<AnyCancellable>()
                    do {
                        let result = try await withCheckedThrowingContinuation { continuation in
                            self.feedService
                                .fetchCatalog(page: nextPage, filter: SeriesFilter(sorting: .newest, isCompleted: true))
                                .sink { series in
                                    continuation.resume(returning: series)
                                }.store(in: &bag)
                                              
//                                .fetchFeed(page: nextPage)
//                                .sink(onNext: { state in
//                                    continuation.resume(returning: state)
//                                }, onError: { error in
//                                    continuation.resume(with: .failure(error))
//                                }).store(in: &bag)
                        }
                        let series = result //result.compactMap { $0.series }
//                        let series = result.compactMap { $0.series }
                        if series.isEmpty {
                            await send(.error)
                        } else {
                            await send(.loaded(series))
                        }
                    } catch {
                        await send(.error)
                    }
                }
                
            case .loaded(let series):
                state.series += series
                state.nextPage += 1
                state.loading = false
            
            case .error:
                print("err")
            
            case .select(let poster):
                guard let series = state.series.first(where: { $0.id == poster.id }) else {
                    return .none
                }
                return .run { send in
                    await send(.selectSeries(series))
                }
                
            case .selectSeries(let series):
                state.selectedSeries = series
            }
            return .none
        }
    }
    private let container: DIContainer
    private let feedService: FeedService
    
    public init(container: DIContainer) {
        self.container = container
        self.feedService = container.resolve()
    }
}

public struct SectionViewTV: View {
    public init(store: StoreOf<SectionTVReducer>) {
        self.store = store
    }
    
    public let store: StoreOf<SectionTVReducer>
    
    var rows: [PosterModel] {
        store.series.compactMap { PosterModel(id: $0.id, title: $0.names.first ?? "", description: $0.desc?.string ?? "", posterUrl: $0.poster) }
    }
    
    public var body: some View {
        if !rows.isEmpty {
            PosterSection(isLoading: store.loading, rows: rows) { model in
                store.send(.select(model))
            } loadMore: {
                store.send(.start)
            }
        }
    }
}
