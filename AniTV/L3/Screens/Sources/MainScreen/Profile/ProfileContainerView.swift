import Foundation
import SwiftUI
import ComposableArchitecture
import DITranquillity
@preconcurrency import ServiceLayer
import Combine

/// Контейнер таба «Профиль»: показывает экран входа для гостя
/// и профиль авторизованного пользователя.
public struct ProfileTabView: View {
    private let container: DIContainer

    public init(container: DIContainer) {
        self.container = container
    }

    public var body: some View {
        ProfileContainerView(
            store: Store(initialState: ProfileContainer.State()) {
                ProfileContainer(container: container)
            },
            container: container
        )
    }
}

// MARK: - Reducer

@Reducer
struct ProfileContainer {
    @ObservableState
    struct State: Equatable {
        enum Screen: Equatable {
            case login
            case profile(User)
        }

        var screen: Screen = .login
        var isCheckingSession = true

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs.screen, rhs.screen) {
            case (.login, .login): return true
            case let (.profile(l), .profile(r)): return l.id == r.id
            default: return false
            }
        }
    }

    enum Action {
        case onAppear
        case sessionState(SessionState)
        case loggedIn(User)
        case loggedOut
    }

    private let container: DIContainer

    var sessionService: SessionService {
        container.resolve()
    }

    init(container: DIContainer) {
        self.container = container
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isCheckingSession = true
                return .run { send in
                    await for sessionState in sessionService.fetchState().values {
                        await send(.sessionState(sessionState))
                    }
                }

            case let .sessionState(session):
                state.isCheckingSession = false
                switch session {
                case let .user(user):
                    state.screen = .profile(user)
                case .guest:
                    state.screen = .login
                }
                return .none

            case let .loggedIn(user):
                state.screen = .profile(user)
                return .none

            case .loggedOut:
                state.screen = .login
                return .none
            }
        }
    }
}

// MARK: - Container view

private struct ProfileContainerView: View {
    @Bindable var store: StoreOf<ProfileContainer>
    let container: DIContainer

    var body: some View {
        Group {
            switch store.screen {
            case .login:
                LoginView(store: Store(initialState: LoginReducer.State()) {
                    LoginReducer(container: container, onAuthSuccess: {
                        store.send(.onAppear) // перезаподписка на состояние сессии → профиль
                    })
                })
            case let .profile(user):
                ProfileView(store: Store(initialState: ProfileReducer.State(user: user)) {
                    ProfileReducer(container: container)
                })
            }
        }
        .overlay {
            if store.isCheckingSession {
                ProgressView()
                    .padding(24)
                    .background(RoundedRectangle(cornerRadius: 12).fill(.regularMaterial))
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}
