//
//  Torrent.swift
//  Anilibria
//
//  Created by Иван Морозов on 23.02.2020.
//  Copyright © 2020 Иван Морозов. All rights reserved.
//

import Foundation

public final class Torrent: NSObject, Decodable {
    public var id: Int = 0
    public var torrentHash: String = ""
    public var leechers: Int = 0
    public var seeders: Int = 0
    public var completed: Int = 0
    public var quality: String = ""
    public var series: String = ""
    public var size: Double = 0
    public var url: URL?
    public var ctime: Date?

    public init(from decoder: Decoder) throws {
        super.init()
		self.id <- decoder["id"]
		self.torrentHash <- decoder["hash"]
		self.leechers <- decoder["leechers"]
		self.seeders <- decoder["seeders"]
		self.completed <- decoder["completed"]
		self.quality <- decoder["quality"]
		self.series <- decoder["series"]
		self.size <- decoder["size"]
		self.url <- decoder["url"] <- URLConverter(Configuration.imageServer)
		self.ctime <- decoder["ctime"] <- DateConverter()
    }
}
