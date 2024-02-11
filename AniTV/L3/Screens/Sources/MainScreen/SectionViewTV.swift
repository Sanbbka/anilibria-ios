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

@Reducer
public struct SectionTVReducer {
    @ObservableState
    public struct State: Equatable {
        public init(nextPage: Int = 0, series: [Series] = [Series]()) {
            self.nextPage = nextPage
            self.series = series
        }
        
        var nextPage = 0
        var series = [Series]()
    }

    public enum Action: Sendable {
        case start
        case loaded([Series]) // поправить сендабл
        case error
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .start:
                print("st")
                let nextPage = state.nextPage
                return .run { send in
                    var bag = Set<AnyCancellable>()
                    do {
                        let result = try await withCheckedThrowingContinuation { continuation in
                            self.feedService
                                .fetchFeed(page: nextPage)
                                .sink(onNext: { state in
                                    continuation.resume(returning: state)
                                }, onError: { error in
                                    continuation.resume(with: .failure(error))
                                }).store(in: &bag)
                        }
                        let series = result.compactMap { $0.series }
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
                state.series = series
                state.nextPage += 1
                print("ed")
            
            case .error:
                print("err")
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
    
    public var body: some View {
        Text("Feed \(store.series.count)").background(Color.red)
        ScrollView (.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<store.series.count, id: \.self) { index in
                    let ser = store.series[index]
                    PosterView(poster: .init(title: ser.names.first ?? "name", posterUrl: ser.poster))
                }
            }.padding(40)
        }
    }
}
