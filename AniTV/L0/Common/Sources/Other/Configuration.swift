import UIKit

public struct Configuration {
    public static var server = "https://www.anilibria.tv"
    public static var imageServer = "https://www.anilibria.tv"
    public static var widgetServer = "https://www.anilibria.tv"
    
    public static func apply(_ settings: AniSettings) {
        self.server = settings.server
        self.imageServer = settings.images
        self.widgetServer = settings.widget
    }
}
