import Foundation
import SwiftUI
import Configurations
import ComposableArchitecture
import MainScreen
import DITranquillity

public struct AniTVView: View {
    let store: StoreOf<AniTVReducer>
    let container: DIContainer
    
    public init(store: StoreOf<AniTVReducer>, container: DIContainer) {
        self.store = store
        self.container = container
    }
    
    public var body: some View {
        
        ConfigurationView().onAppear(perform: {
            store.send(.startLoad)
        })
        
        if store.configurationLoaded {
            if let store = store.scope(state: \.startStateSection, action: \.configDidLoad) {
                SectionViewTV(store: store)
            }
        }
    }
}
