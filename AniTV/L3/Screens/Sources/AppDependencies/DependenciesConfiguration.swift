import DITranquillity
import Kingfisher
import UIKit
import ServiceLayer
import Common

public protocol DependenciesConfiguration: AnyObject {
    func setup()
    func configuredContainer() -> DIContainer
}

public class DependenciesConfigurationBase: DependenciesConfiguration, Loggable {
   public init() {}

    // MARK: - Configure

    public var defaultLoggingTag: LogTag {
        return .unnamed
    }

    public func configuredContainer() -> DIContainer {
        let container = DIContainer()
        container.append(framework: AppFramework.self)
        return container
    }

    // MARK: - Setup

    public func setup() {
        self.setupModulesDependencies()
    }

    private func setupModulesDependencies() {
        // logger
        let logger = Logger.sharedInstance
        let swiftyLogger = SimpleLogger()
        logger.setupLogger(swiftyLogger)
        Logger.setSharedInstance(logger)
    }
}
