//
//  UIImageView+ALBImageLoader.swift
//  LazyLoadingImages


import UIKit

private var activityIndicatorKey: UInt8 = 0
private var imageURLKey: UInt8 = 0

public extension UIImageView {
    
    var activityIndicator: UIActivityIndicatorView {
        get {
            return associatedObject(self, key: &activityIndicatorKey)
                { return UIActivityIndicatorView() } // Set the initial value of the var
        }
        set { associateObject(self, key: &activityIndicatorKey, value: newValue) }
    }
    
    fileprivate var associatedImageUrlString: NSString {
        get {
            return associatedObject(self, key: &imageURLKey)
                { return "" } // Set the initial value of the var
        }
        set { associateObject(self, key: &imageURLKey, value: newValue) }
    }
    
    /**
     Sets the image from the url provided. Completion block provides the status and downloaded image, if success
     - parameter url: The url to dowbload the image
     - parameter placeholderImage: shows the placeholder image till the download completes
     - parameter activityIndicatorStyle: style of the activity indicator to be shown. The activity indicator is added to the imageview @center till the download completes
     */
    func setImageWithURL(_ url: URL, placeholderImage: UIImage, activityIndicatorStyle style: UIActivityIndicatorView.Style, completion: @escaping (_ status: Bool, _ image: UIImage?) -> Void) {
        let loader = ALBImageLoader.sharedInstance
        self.associatedImageUrlString = url.absoluteString as NSString
        
        // set the placeholder image
        self.image = placeholderImage
        self.layoutIfNeeded()
        self.setupActivityIndicator(style)
        
        //make the network call to fetch the image
        loader.startDownload(url) { (status, image, request) -> Void in
            OperationQueue.main.addOperation { () -> Void in
                if let image = image, status == true && (self.associatedImageUrlString as String) == request.url?.absoluteString {
                    self.image = image
                    self.layoutIfNeeded()
                    self.removeActivityIndicator()
                } else if !status {
                    self.removeActivityIndicator()
                }
                
                completion(status, image)
            }
        }
        
    }
    
    fileprivate func setupActivityIndicator(_ style: UIActivityIndicatorView.Style) {
        self.activityIndicator.autoresizingMask = UIView.AutoresizingMask()
        self.activityIndicator.center = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        self.activityIndicator.style = style
        
        OperationQueue.main.addOperation { () -> Void in
            self.activityIndicator.startAnimating()
            self.addSubview(self.activityIndicator)
        }
    }
    
    /**
     Removes the activity indicator on the imageview
     */
    func removeActivityIndicator() {
        OperationQueue.main.addOperation { () -> Void in
            self.activityIndicator.startAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    
}

public func associatedObject<ValueType: AnyObject>(
    _ base: AnyObject,
    key: UnsafePointer<UInt8>,
    initialiser: () -> ValueType)
    -> ValueType {
        if let associated = objc_getAssociatedObject(base, key) as? ValueType { return associated }
        let associated = initialiser()
        objc_setAssociatedObject(base, key, associated,
            .OBJC_ASSOCIATION_RETAIN)
        return associated
}

public func associateObject<ValueType: AnyObject>(
    _ base: AnyObject,
    key: UnsafePointer<UInt8>,
    value: ValueType) {
        objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
}
