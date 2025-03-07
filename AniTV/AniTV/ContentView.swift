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
import DITranquillity
import ServiceLayer

nonisolated(unsafe) var dependencyConfigurationContainer: DIContainer  = {
    let config = DependenciesConfigurationBase()
    config.setup()
    
    return config.configuredContainer()
}()

struct ContentView: View {
    let container = DependencyContainer(container: dependencyConfigurationContainer)
    let store = Store(
        initialState: AniTVReducer.State()) {
            AniTVReducer(
                container:dependencyConfigurationContainer
            )
            ._printChanges()
        }
    
    var body: some View {
        AniTVView(
            store: store,
            container: dependencyConfigurationContainer
        )
        .environmentObject(container)
    }
}
