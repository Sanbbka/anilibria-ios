//
//  ContentView.swift
//  AniTV
//
//  Created by Alexander Drovnyashin on 8/2/24.
//

import SwiftUI
import SwiftData
import ComposableArchitecture
import App
import AppDependencies

var dependencyConfiguration: DependenciesConfigurationBase = {
    let config = DependenciesConfigurationBase()
    config.setup()
    
    return config
}()

struct ContentView: View {
    let store = Store(
        initialState: AniTVReducer.State()) {
            AniTVReducer(container: dependencyConfiguration.configuredContainer())._printChanges()
        }
    
    var body: some View {
        AniTVView(store: store)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
