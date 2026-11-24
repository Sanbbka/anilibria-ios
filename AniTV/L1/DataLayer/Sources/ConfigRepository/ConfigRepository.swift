import DITranquillity
import Combine
import Foundation

public final class ConfigRepositoryPart: DIPart {
    public static func load(container: DIContainer) {
        container.register(ConfigRepositoryImp.init)
            .as(ConfigRepository.self)
            .lifetime(.single)
    }
}

public protocol ConfigRepository {
    func set(config: AniConfig)
    func getConfig() -> AniConfig?

    func set(configInfo: AniConfigInfo)
    func getConfigInfo() -> AniConfigInfo?

    func getCurrentSettings() -> AniSettings?
    func setCurrent(settings: AniSettings)
}

final class ConfigRepositoryImp: ConfigRepository {
    private let keyConfig: String = "ANI_CONFIG_KEY"
    private let keyConfigInfo: String = "ANI_CONFIG_INFO_KEY"
    private let keySettings: String = "ANI_SETTINGS_KEY"

    func set(config: AniConfig) {
        UserDefaults.standard[keyConfig] = config
    }

    func getConfig() -> AniConfig? {
        UserDefaults.standard[keyConfig]
    }

    func set(configInfo: AniConfigInfo) {
        UserDefaults.standard[keyConfigInfo] = configInfo
    }

    func getConfigInfo() -> AniConfigInfo? {
        UserDefaults.standard[keyConfigInfo]
    }

    func setCurrent(settings: AniSettings) {
        UserDefaults.standard[keySettings] = settings
    }

    func getCurrentSettings() -> AniSettings? {
        UserDefaults.standard[keySettings]
    }
}
