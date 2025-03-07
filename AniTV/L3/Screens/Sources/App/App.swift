import Foundation
import SwiftUI
import Configurations
import ComposableArchitecture
import MainScreen
import DITranquillity
import Components
import ServiceLayer

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
            ConfigurationView().onAppear(perform: {
                store.send(.startLoad)
            })
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
                Text("Избранное (не реализовано)")
                    .tag(2)
                    .tabItem {
                        Text("Избранное")
                    }
                Text("Прочее (не реализовано)")
                    .tag(3)
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
