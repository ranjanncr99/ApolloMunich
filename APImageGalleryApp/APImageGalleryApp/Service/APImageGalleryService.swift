//
//  APImageGalleryService.swift
//  APImageGalleryApp

//  Copyright © 2019 Ranjan. All rights reserved.
//

import Foundation

class APImageGalleryService {
    
    func performRequest(endPointUrl: URL, completion:@escaping (APImageListModel?, Error?) -> Void) {
        let dataTask  = URLSession(configuration: .default).dataTask(with: requestWithURL(url: endPointUrl), completionHandler: {(data, response, error) in
            
            if error != nil {
                completion(nil, error)
            }
            else {
                guard let data = data else {
                    completion(nil, error)
                    return
                }

                let photoImageListModel = try? JSONDecoder().decode(APImageListModel.self, from: data)
                completion(photoImageListModel, nil)
            }
        })
        
        dataTask.resume()
    }
    
    
    func requestWithURL(url: URL) -> URLRequest  {
        var request: URLRequest = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
}
