import Foundation
import SwiftUI
import ComposableArchitecture
import DITranquillity
@preconcurrency import ServiceLayer
import Combine

// MARK: - Reducer

@Reducer
public struct LoginReducer {
    @ObservableState
    public struct State: Equatable {
        public var login = ""
        public var password = ""
        public var code = ""
        public var isSubmitting = false
        public var errorMessage: String?
        public var isAuthorized = false

        public var canSubmit: Bool {
            !login.isEmpty && !password.isEmpty && !isSubmitting
        }

        public init() {}
    }

    public enum Action {
        case binding(BindingAction<State>)
        case submitTapped
        case codeTapped(String)
        case codeCleared
        case loginSucceeded
        case loginFailed(String)
        case dismissError
        case authSucceeded
    }

    private let container: DIContainer

    var sessionService: SessionService {
        container.resolve()
    }

    /// Вызывается после успешного логина, чтобы родительский экран
    /// мог переключиться на профиль.
    var onAuthSuccess: (() -> Void)?

    init(container: DIContainer, onAuthSuccess: (() -> Void)? = nil) {
        self.container = container
        self.onAuthSuccess = onAuthSuccess
    }

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.login), .binding(\.password):
                state.errorMessage = nil
                return .none

            case .binding:
                return .none

            case let .codeTapped(digit):
                if state.code.count < 6 {
                    state.code += digit
                }
                return .none

            case .codeCleared:
                if !state.code.isEmpty {
                    state.code.removeLast()
                }
                return .none

            case .submitTapped:
                guard state.canSubmit else { return .none }
                state.isSubmitting = true
                state.errorMessage = nil
                let login = state.login
                let password = state.password
                let code = state.code
                return .run { send in
                    await withTaskCancellationHandler {
                        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
                            var bag = Set<AnyCancellable>()
                            sessionService
                                .signIn(login: login, password: password, code: code)
                                .sink(receiveCompletion: { completion in
                                    switch completion {
                                    case .finished:
                                        break
                                    case let .failure(error):
                                        Task { await send(.loginFailed(error.localizedDescription)) }
                                    }
                                    continuation.resume()
                                }, receiveValue: { _ in
                                    Task { await send(.loginSucceeded) }
                                    continuation.resume()
                                })
                                .store(in: &bag)
                        }
                    } onCancel: {}
                }

            case .loginSucceeded:
                state.isSubmitting = false
                state.isAuthorized = true
                // Пробрасываем событие наверх: родительский контейнер
                // переключит экран и получит пользователя из состояния сессии.
                onAuthSuccess?()
                return .send(.authSucceeded)

            case .authSucceeded:
                return .none

            case let .loginFailed(message):
                state.isSubmitting = false
                state.errorMessage = message
                return .none

            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}

// MARK: - View

public struct LoginView: View {
    @Bindable public var store: StoreOf<LoginReducer>

    public init(store: StoreOf<LoginReducer>) {
        self.store = store
    }

    public var body: some View {
        ZStack {
            background

            VStack(spacing: 24) {
                header
                    .padding(.top, 32)

                HStack(alignment: .top, spacing: 40) {
                    VStack(spacing: 20) {
                        credentialsForm
                        twoFactorField
                        submitButton
                    }
                    .frame(maxWidth: 520)

                    TwoFactorKeypad(
                        onDigit: { store.send(.codeTapped($0)) },
                        onClear: { store.send(.codeCleared) }
                    )
                }
                .padding(.horizontal, 64)
            }

            if let message = store.errorMessage {
                errorOverlay(message)
            }
        }
        .preferredFocusMode(.sequential)
    }

    // MARK: Pieces

    private var background: some View {
        Image("back_1", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .mask {
                        LinearGradient(
                            stops: [
                                .init(color: .black.opacity(0.75), location: 0),
                                .init(color: .black.opacity(0.55), location: 0.5),
                                .init(color: .black.opacity(0.85), location: 1)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    }
            }
            .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Anilibria")
                .font(.system(size: 44, weight: .bold, design: .rounded))
            Text("Войдите, чтобы синхронизировать избранное и историю просмотра")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 48)
    }

    private var credentialsForm: some View {
        VStack(spacing: 16) {
            TextField("Логин или e-mail", text: $store.login)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($loginFocused)

            SecureField("Пароль", text: $store.password)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($passwordFocused)
                .onSubmit { store.send(.submitTapped) }
        }
        .textFieldStyle(.plain)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
        )
        .onAppear { loginFocused = true }
    }

    private var twoFactorField: some View {
        HStack(spacing: 12) {
            Text("2FA код")
                .foregroundStyle(.secondary)
            Text(store.code.isEmpty ? "—— ——" : store.code)
                .fontWeight(.semibold)
                .monospacedDigit()
                .frame(minWidth: 90, alignment: .leading)
            Spacer()
            Text("(если включена двухфакторная авторизация)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
        )
    }

    private var submitButton: some View {
        Button {
            store.send(.submitTapped)
        } label: {
            HStack(spacing: 12) {
                if store.isSubmitting {
                    ProgressView()
                        .controlSize(.small)
                }
                Text(store.isSubmitting ? "Входим…" : "Войти")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 14))
        .disabled(!store.canSubmit)
        .tint(.red)
    }

    private func errorOverlay(_ message: String) -> some View {
        VStack {
            Spacer()
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                Text(message)
                    .foregroundStyle(.primary)
                Button("OK") {
                    store.send(.dismissError)
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.thickMaterial)
            )
            .padding(.horizontal, 96)
            .padding(.bottom, 48)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    @FocusState private var loginFocused: Bool
    @FocusState private var passwordFocused: Bool
}

// MARK: - Numpad for 2FA (tvOS-friendly)

struct TwoFactorKeypad: View {
    let onDigit: (String) -> Void
    let onClear: () -> Void

    private let rows: [[String]] = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["⌫", "0"]]

    var body: some View {
        VStack(spacing: 12) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button(key) {
                            if key == "⌫" {
                                onClear()
                            } else {
                                onDigit(key)
                            }
                        }
                        .font(.title3.weight(.medium))
                        .frame(width: 84, height: 56)
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}
