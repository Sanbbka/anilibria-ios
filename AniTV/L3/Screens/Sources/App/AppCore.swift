import Foundation
import ComposableArchitecture
import ServiceLayer
import DITranquillity
import Combine

private var bag = Set<AnyCancellable>()

@Reducer
public struct AniTVReducer: Reducer {
    @ObservableState
    public struct State {
        public var configurationLoading = false
        public var configurationLoaded = false
        
        public init(configurationLoaded: Bool = false) {
            self.configurationLoaded = configurationLoaded
        }
    }
    public enum Action {
        case startLoad
        case configDidLoad
        case error
    }
    
    public let container: DIContainer
    
    var appService: AppConfigurationService {
        container.resolve()
    }
    public init(container: DIContainer) {
        self.container = container
        
        
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .startLoad:
                state.configurationLoaded = false
                state.configurationLoading = true
                
                return .run { send in
                    do {
                        let result = try await withCheckedThrowingContinuation { continuation in
                            self.appService
                                .startConfiguration()
                                .sink(onNext: { state in
                                    continuation.resume(returning: state)
                                }, onError: { error in
                                    continuation.resume(with: .failure(error))
                                }).store(in: &bag)
                        }
                        if result == .completed {
                            await send(.configDidLoad)
                        } else {
                            await send(.error)
                        }
                    } catch {
                        await send(.error)
                    }
                }
                
            case .configDidLoad:
                state.configurationLoaded = true
                state.configurationLoading = false
            
            case .error:
                print("error")
            }
            
            return .none
        }
    }
}
