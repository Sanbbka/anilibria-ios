import Foundation
import SwiftUI
import ComposableArchitecture
import DITranquillity
@preconcurrency import ServiceLayer
import Combine

// MARK: - Reducer

@Reducer
public struct ProfileReducer {
    @ObservableState
    public struct State: Equatable {
        public var user: User?
        public var isLoading = false
        public var errorMessage: String?
        public var isLoggedOut = false

        public init(user: User? = nil) {
            self.user = user
        }
    }

    public enum Action {
        case onAppear
        case userLoaded(User)
        case userFailed(String)
        case refreshTapped
        case logoutTapped
        case dismissed
    }

    private let container: DIContainer

    var sessionService: SessionService {
        container.resolve()
    }

    public init(container: DIContainer) {
        self.container = container
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refreshTapped:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                        var bag = Set<AnyCancellable>()
                        sessionService
                            .fetchUser()
                            .sink(receiveCompletion: { completion in
                                if case let .failure(error) = completion {
                                    Task { await send(.userFailed(error.localizedDescription)) }
                                }
                                continuation.resume()
                            }, receiveValue: { user in
                                Task { await send(.userLoaded(user)) }
                                continuation.resume()
                            })
                            .store(in: &bag)
                    }
                }

            case let .userLoaded(user):
                state.isLoading = false
                state.user = user
                return .none

            case let .userFailed(message):
                state.isLoading = false
                state.errorMessage = message
                return .none

            case .logoutTapped:
                sessionService.logout()
                state.user = nil
                state.isLoggedOut = true
                return .send(.dismissed)

            case .dismissed:
                return .none
            }
        }
    }
}

// MARK: - View

public struct ProfileView: View {
    @Bindable public var store: StoreOf<ProfileReducer>
    @Environment(\.dismiss) private var dismiss

    public init(store: StoreOf<ProfileReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.92).ignoresSafeArea()

            VStack(spacing: 28) {
                header

                if let user = store.user {
                    userInfoCard(user)
                    menuList
                } else {
                    emptyState
                }

                Spacer()
            }
            .padding(.horizontal, 64)
            .padding(.top, 32)
        }
        .task {
            if store.user == nil {
                store.send(.onAppear)
            }
        }
        .onChange(of: store.isLoggedOut) { _, loggedOut in
            if loggedOut {
                dismiss()
            }
        }
    }

    // MARK: Pieces

    private var header: some View {
        HStack {
            Text("Профиль")
                .font(.system(size: 38, weight: .bold, design: .rounded))
            Spacer()
            Button {
                store.send(.refreshTapped)
            } label: {
                Image(systemName: "arrow.clockwise")
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.bordered)
        }
    }

    private func userInfoCard(_ user: User) -> some View {
        HStack(spacing: 20) {
            AsyncImage(url: user.avatar) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                default:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 84, height: 84)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(user.name)
                    .font(.title2.weight(.semibold))
                Text("ID: \(user.id)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if store.isLoading {
                ProgressView()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.regularMaterial)
        )
    }

    private var menuList: some View {
        VStack(spacing: 12) {
            profileRow(icon: "heart.fill", title: "Избранное", subtitle: "Сериалы, которые вы сохранили")
            profileRow(icon: "clock.fill", title: "История просмотров", subtitle: "Продолжить с того, где остановились")
            profileRow(icon: "gearshape.fill", title: "Настройки", subtitle: "Качество воспроизведения и субтитры")

            Button {
                store.send(.logoutTapped)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(.red)
                        .frame(width: 32)
                    Text("Выйти из аккаунта")
                        .foregroundStyle(.red)
                    Spacer()
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.regularMaterial)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func profileRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(.tint)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text(store.errorMessage ?? "Не удалось загрузить профиль")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Повторить") {
                store.send(.refreshTapped)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(32)
    }
}
