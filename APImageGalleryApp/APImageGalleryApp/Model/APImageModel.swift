//
//  APImageModel.swift
//  APImageGalleryApp

//  Copyright © 2019 Ranjan. All rights reserved.
//

import Foundation

struct APImageListModel: Codable {
    var title = ""
    var link = ""
    var description = ""
    var modified = ""
    var generator = ""
    var items: [APImageModel] = []
}

struct APImageModel: Codable {
    var title = ""
    var link = ""
    var dateTaken = ""
    var description = ""
    var published = ""
    var author = ""
    var authorId = ""
    var tags = ""
    var media: APMedia = APMedia()
    
    enum CodingKeys: String, CodingKey {
        case dateTaken = "date_taken"
        case authorId = "author_id"
        case title = "title"
        case link = "link"
        case media = "media"
        case description = "description"
        case published = "published"
        case author = "author"
        case tags = "tags"
    }
    
    struct APMedia: Codable {
        var m = ""
    }
}

