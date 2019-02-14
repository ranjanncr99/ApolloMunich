//
//  ImageLoader.swift
//  LazyLoadingImages

import UIKit
/**
 ALBImageLoader provides methods to download the images and manage the data tasks. The downloaded images are saved to the memory (ALBImageCache) and NSCachesDirectory based on the request provided and image's URL
 */
open class ALBImageLoader: NSObject {
    
    public static let sharedInstance = ALBImageLoader()
    fileprivate override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector:#selector(ALBImageLoader.clearCache(_:)), name:UIApplication.willTerminateNotification, object:nil)
    }
    fileprivate lazy var imagefetchqueue = OperationQueue()

    public enum FileType {
        case jpg, png
        
        var description: String {
            switch self {
            case .jpg: return ".jpg"
            case .png: return ".png"
            }
        }
    }
    
    open var imageFiletype: FileType = .png
    lazy var sessionTask = URLSessionDataTask()
    lazy var cachesDirectoryURLString: String? = {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
    }()
    
    /**
     Downloads the image for the provided image URL
     - parameter imageURL: Image URL location to download the image from
     - parameter completion: This completion blocks provides the status of the download task and optional image if successful
     */
    open func startDownload(_ imageURL: URL, imageRequest: URLRequest? = nil, completion: @escaping (_ status: Bool, _ image: UIImage?, _ request: URLRequest) -> Void) {
        self.imagefetchqueue.addOperation { () -> Void in
            DLog("Image URL: \(imageURL.absoluteString)")
            
            // create request for the url
            let request = imageRequest ?? URLRequest(url: imageURL)
            let imageIdentifier = imageURL.hashValue
            let imageIdentifierString = "\(imageIdentifier)"
            let imageFileName = imageIdentifierString + self.imageFiletype.description
            let imagePath = self.getDiskPath(imageFileName)
            
            if self.shouldFetchFromMemory(forRequest: request) {
                if let image: UIImage = ALBImageCache.sharedInstance.cachedImage(imageIdentifier: imageIdentifierString) {
                    DLog("Image found in memory, Loading...")
                    completion(true, image, request)
                    return
                }
                
                if let image = self.loadImageFromPath(imagePath) {
                    DLog("Image found in cache, Loading...")
                    completion(true, image, request)
                    
                    DLog("Loading the image into memory for future use...")
                    ALBImageCache.sharedInstance.cacheImage(image, imageIdentifier: imageIdentifierString)
                    return
                }
            }
            
            DLog("Creating a NSURLSession to download the image")
            self.sessionTask = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                
                // check status code
                guard let response = response as? HTTPURLResponse, response.statusCode == 200  else {
                    DLog("Failed to downlaod image from " + imageURL.absoluteString)
                    completion(false, nil, request)
                    return
                }
                
                // check for errors
                
                if let error = error as NSError? {
                    if #available(iOS 9.0, *) {
                        if error.code == NSURLErrorAppTransportSecurityRequiresSecureConnection
                        {
                            assertionFailure("NSURLErrorAppTransportSecurityRequiresSecureConnection - Info.plist has not been properly configured to match the target server")
                        }
                    }
                    
                    DLog(error)
                    completion(false, nil, request)
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    DLog("Image Downloaded Success. Saving the image to Cache..")
                    ALBImageCache.sharedInstance.cacheImage(image, imageIdentifier: imageIdentifierString)
                    self.saveImage(image, path: imagePath)
                    completion(true, image, request)
                    return
                } else {
                    DLog("Invalid Data - UIImage")
                    completion(false, nil, request)
                    return
                }
                
            })
            
            self.sessionTask.resume()
        }
    }
    
    /**
     Saves the image to the specified path
     - parameter image: Image to be saved. Converts the image to selected file type default being PNG
     - parameter path: Disk location path to save the image
     */
    @discardableResult
    func saveImage(_ image: UIImage, path: String ) -> Bool {
        var imageData: Data?
        
        switch self.imageFiletype {
        case .jpg:
            imageData = image.jpegData(compressionQuality: 1.0)
        case .png:
            imageData = image.pngData()
        }
        
        guard let _ = imageData else {
            DLog("Saving to Cache Folder Failed: no CGImageRef or invalid bitmap format for " + image.description)
            return false }
        
        let result = (try? imageData!.write(to: URL(fileURLWithPath: path), options: [.atomic])) != nil
        return result
    }
    
    /**
     Fetches the image from the given path. Returns nil if image not found
     - parameter path: Disk location path to fetch the image from
     */
    func loadImageFromPath(_ path: String) -> UIImage? {
        DLog("Loading image from path: \(path)") // this is just for you to see the path in case you want to go to the directory, using Finder.
        let image = UIImage(contentsOfFile: path)
        return image
    }

    /**
    Cancels all the tasks in the queue, if not completed
    */
    open func cancelAllDownloads() {
        self.imagefetchqueue.cancelAllOperations()
    }
    
    /**
     This method specifies whether the image should be used from the cache or not.
     - parameter request: If the request has a cache policy of either ReloadIgnoringCacheData or ReloadIgnoringLocalAndRemoteCacheData, ignores the data stored in the memory
     - returns: An image found for the provided request
     */
    func shouldFetchFromMemory(forRequest request: URLRequest) -> Bool {
        switch (request.cachePolicy) {
        case .reloadIgnoringLocalCacheData, .reloadIgnoringLocalAndRemoteCacheData: return false
        default: return true
        }
    }
    
    /**
     This method specifies whether the image should be used from the cache or not.
     - parameter request: If the request has a cache policy of either ReloadIgnoringCacheData or ReloadIgnoringLocalAndRemoteCacheData, ignores the data stored in the memory
     - returns: An image found for the provided request
     */
    open func getDiskPath(_ fileName: String) -> String {
        let cachesDirectoryPathString : NSString
        if let cacheDirectoryAsString = cachesDirectoryURLString {
            cachesDirectoryPathString = cacheDirectoryAsString as NSString
        } else {
            return ""
        }
        
        let imagesPath = cachesDirectoryPathString.appendingPathComponent("ALBImages") as NSString
        let fileManager = FileManager.default
        let directoryExists = fileManager.fileExists(atPath: imagesPath as String)
        if !directoryExists {
            _ = try? fileManager.createDirectory(atPath: imagesPath as String, withIntermediateDirectories: true, attributes: nil)
        }
        let imagePath = imagesPath.appendingPathComponent(fileName)
        return imagePath
    }
    
    /**
     This method clears the complete directory where the dowloaded images are stored.
     */
    fileprivate func clearStoredImages() {
        let fileManager = FileManager.default
        let cachesDirectoryPathString : NSString

        guard let cacheDirectoryAsString = cachesDirectoryURLString else {
            DLog("Can't find ALBImages")

            return
        }
        cachesDirectoryPathString = cacheDirectoryAsString as NSString

        let folderPath = cachesDirectoryPathString.appendingPathComponent("ALBImages")
        do {
            try fileManager.removeItem(atPath: folderPath)
        } catch let error as NSError {
            DLog(error.localizedDescription)
        }
    }
    
    @objc func clearCache(_ notification:Foundation.Notification) {
        DLog("Clearing cache data...")
        self.clearStoredImages()
    }
    
}

/**
 ALBImageCache is a subclass of NSCache which is used to save the images in memory.
 Set the maximum allowed NSCache to be used by your application in the appdelegate.
 */
open class ALBImageCache: NSCache<AnyObject, AnyObject> {
    static let sharedInstance: ALBImageCache = ALBImageCache()
    fileprivate override init() {}
    
    /**
     Fetches the image from the cache (memory)
     - parameter imageIdentifier: The image identifier is used as the key to identify the image.
     - returns: An image found for the provided request
     */
    open func cachedImage(imageIdentifier identifier: String) -> UIImage? {
        return self.object(forKey: identifier as AnyObject) as? UIImage
    }
    
    /**
     Saves the image to the cache (memory) for the provided request
     - parameter image: The image to be saved
     - parameter imageIdentifier: The image identifier is used as the identifer to save the image
     - returns: An image found for the provided request
     */
    open func cacheImage(_ image: UIImage, imageIdentifier identifier: String) {
        self.setObject(image, forKey: identifier as AnyObject)
    }
    
    /**
     Clears the Image Cache, removes all the objects stored
     - Note: iOS takes care of maintaining/clearing the cache. Only use this function to manually remove them, if required.
     */
    open func clearImageCache() {
        ALBImageCache.sharedInstance.removeAllObjects()
    }
}

/**
 Debug log - prints the given items only if the DEBUG flag is defined
 - parameter items: Accepts a closed range of objects of data type "Any"
 */
public func DLog(_ items: Any...) {
    #if DEBUG
        print(items)
    #endif
}
