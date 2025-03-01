import Foundation
import SwiftUI
import Configurations
import ComposableArchitecture
import MainScreen
import DITranquillity
import Components

public struct AniTVView: View {
    let store: StoreOf<AniTVReducer>
    let container: DIContainer
    
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
            if let store = store.scope(state: \.startStateSection, action: \.configDidLoad) {
                HStack {
                    SectionViewTV(store: store).frame(maxWidth: .infinity)
                    
                    Text("Правая сторона")
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                }
            }
        }
    }
}
