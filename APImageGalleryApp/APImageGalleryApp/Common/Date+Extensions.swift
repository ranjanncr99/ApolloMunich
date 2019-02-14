//
//  Date+Extensions.swift
//  APImageGalleryApp

//  Copyright © 2019 Ranjan. All rights reserved.
//

import Foundation

extension Date {
    
    static func dateFromString(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
}
