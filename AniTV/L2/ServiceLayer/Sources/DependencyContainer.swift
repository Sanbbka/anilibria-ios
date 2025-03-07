import Foundation
import DITranquillity

public final class DependencyContainer: ObservableObject {
    public let container: DIContainer
    
    public init(container: DIContainer) {
        self.container = container
    }
}
