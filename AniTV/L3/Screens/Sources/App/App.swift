import Foundation
import SwiftUI
import Configurations
import ComposableArchitecture

public struct AniTVView: View {
    let store: StoreOf<AniTVReducer>
    
    public init(store: StoreOf<AniTVReducer>) {
        self.store = store
        store.send(.startLoad)
    }
    
    public var body: some View {
        if store.configurationLoading {
            ConfigurationView()
        } else {
            Text("Конфиг загружен")
        }
    }
}
