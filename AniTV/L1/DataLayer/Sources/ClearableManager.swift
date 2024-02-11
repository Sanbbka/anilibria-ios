import Foundation

public protocol Clearable {
    func clear()
}

public protocol ClearableManager: Clearable {}

public final class ClearableManagerImp: ClearableManager {
    private let items: [Clearable]

    public init(items: [Clearable]) {
        self.items = items
    }

    public func clear() {
        self.items.forEach { $0.clear() }
    }
}
