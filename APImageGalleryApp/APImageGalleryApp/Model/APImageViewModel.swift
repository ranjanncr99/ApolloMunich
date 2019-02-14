//
//  APImageViewModel.swift
//  APImageGalleryApp

//  Copyright © 2019 Ranjan. All rights reserved.
//

import Foundation

class APImageViewModel {
    
    var results: [APImageModel]?
    var imageModel: APImageModel?

    init(results: [APImageModel]) {
        self.results = results
        sortByCreationDate()
    }
    
    func viewModelForIndex(index: Int) {
        imageModel = self.results?[index]
    }
    
    var imageUrlPath: String? {
        get {
            return imageModel?.media.m
        }
    }
    
    var photoTitle: String? {
        get {
            return imageModel?.title
        }
    }
    
    var resultCount: Int? {
        get {
            return results?.count
        }
    }
    
    var publishedDate: String? {
        get {
            return imageModel?.published
        }
    }
    
    var creationDate: String? {
        get {
            return imageModel?.dateTaken
        }
    }
    
    func sortByCreationDate() {
        let sortedArray = results?.sorted(by: { Date.dateFromString($0.dateTaken) > Date.dateFromString($1.dateTaken) })
        results = sortedArray
    }
    
    func sortByPublishedDate() {
        let sortedArray = results?.sorted(by: { Date.dateFromString($0.published) > Date.dateFromString($1.published) })
        results = sortedArray
    }
}


