import Foundation

public struct AniConfig: Codable {
    public let addresses: [AniAddress]
}

public struct AniAddress: Codable {
    public let name: String?
    public let base: String
    public let baseImages: String
    public let widgetsSite: String
    public let proxies: [AniProxy]
}

public struct AniProxy: Codable {
    public let tag: String?
    public let name: String?
    public let desc: String?
    public let ip: String
    public let port: Int
    public let user: String?
    public let password: String?

    public func config() -> [AnyHashable: Any] {
        var proxyConfiguration = [String: Any]()
        proxyConfiguration.updateValue(1, forKey: "HTTPEnable")
        proxyConfiguration.updateValue(ip, forKey: "HTTPProxy")
        proxyConfiguration.updateValue(port, forKey: "HTTPPort")
        proxyConfiguration.updateValue(1, forKey: "HTTPSEnable")
        proxyConfiguration.updateValue(ip, forKey: "HTTPSProxy")
        proxyConfiguration.updateValue(port, forKey: "HTTPSPort")
        return proxyConfiguration
    }
}

public final class AniSettings: Codable {
    public let server: String
    public let images: String
    public let widget: String
    public let proxy: AniProxy?
    public var next: AniSettings?

    public init(address: AniAddress, proxy: AniProxy?) {
        self.server = address.base
        self.images = address.baseImages
        self.widget = address.widgetsSite
        self.proxy = proxy
    }

    public static func create(from config: AniConfig) -> AniSettings? {
        var result: AniSettings?
        var current: AniSettings?
        for address in config.addresses {
            let settings = AniSettings(address: address, proxy: nil)
            current?.next = settings
            if current == nil {
                result = settings
            }
            current = settings
        }

        for address in config.addresses {
            for proxy in address.proxies {
                let settings = AniSettings(address: address, proxy: proxy)
                current?.next = settings
                current = settings
            }
        }

        return result
    }

    private init(server: String, images: String, widget: String) {
        self.server = server
        self.images = images
        self.widget = widget
        self.proxy = nil
        self.next = nil
    }

    public static let `default`: AniSettings = AniSettings(server: "https://www.anilibria.tv",
                                                    images: "https://www.anilibria.tv",
                                                    widget: "https://www.anilibria.tv")
}
