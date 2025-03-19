import Foundation
import SwiftUI
import Configurations
import ComposableArchitecture
import MainScreen
import DITranquillity
import Components
import ServiceLayer

public var splash: Image {
    back_1
}

public struct AniTVView: View {
    let store: StoreOf<AniTVReducer>
    let container: DIContainer
    
    @State private var selectedTabIndex = 0
    
    @EnvironmentObject
    var dependencyContainer: DependencyContainer
    
    public init(store: StoreOf<AniTVReducer>, container: DIContainer) {
        self.store = store
        self.container = container
    }
    
    public var body: some View {
        if store.configurationLoading {
            ZStack {
                splash
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .mask {
                                LinearGradient(
                                    stops: [
                                        .init(color: .white, location: 0.2),
                                        .init(color: .white.opacity(0.7), location: 0.4),
                                        .init(color: .white.opacity(0), location: 0.56),
                                        .init(color: .white.opacity(0), location: 0.7),
                                        .init(color: .white.opacity(0.25), location: 0.8)
                                    ],
                                    startPoint: .bottom, endPoint: .top
                                )
                            }
                    }
                    .ignoresSafeArea()
                ConfigurationView().onAppear(perform: {
                    store.send(.startLoad)
                })
            }
        }
        
        if store.configurationLoaded {
            TabView(selection: $selectedTabIndex) {
                feedContent()
                    .tag(0)
                    .tabItem {
                        Text("Расписание")
                    }
                searchContent()
                    .tag(1)
                    .tabItem {
                        Text("Поиск")
                    }
                
                CatalogView()
                    .tag(2)
                    .tabItem {
                        Text("Каталог")
                    }
                
                Text("Избранное (не реализовано)")
                    .tag(3)
                    .tabItem {
                        Text("Избранное")
                    }
                Text("Прочее (не реализовано)")
                    .tag(4)
                    .tabItem {
                        Text("Прочее")
                    }
            }
        }
    }
    
    @ViewBuilder
    func searchContent() -> some View {
        SearchView()
    }
    
    @ViewBuilder
    func feedContent() -> some View {
        if let store = store.scope(state: \.startStateSection, action: \.configDidLoad) {
            HStack {
                SectionViewTV(store: store).frame(maxWidth: .infinity)
                
                VStack {
                    if let series = self.store.startStateSection?.selectedSeries {
                        SeriesPageView(series: series, container: dependencyContainer.container).id(series.id)
                    }
                }.frame(maxWidth: .infinity)
            }
        }
    }
}
