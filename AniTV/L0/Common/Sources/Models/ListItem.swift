import UIKit

public class ListItem<T>: NSObject {
    var value: T

    public init(_ value: T) {
        self.value = value
    }
}
