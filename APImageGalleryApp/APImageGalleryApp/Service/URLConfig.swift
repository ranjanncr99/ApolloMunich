//
//  URLConfig.swift
//  APImageGalleryApp

//  Copyright © 2019 Ranjan. All rights reserved.
//

import Foundation

struct URLConfig {
    static let endPoint = "https://api.flickr.com/services/feeds/photos_public.gne/?page=10&format=json&nojsoncallback=1"
    static let searchEndPoint = "https://api.flickr.com/services/feeds/photos_public.gne/?tags=%@&format=json&nojsoncallback=1"
}
