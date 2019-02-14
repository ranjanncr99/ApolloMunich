//
//  APPhotoCollectionViewCell.swift
//  APImageGalleryApp

//  Copyright © 2019 Ranjan. All rights reserved.
//

import UIKit


class APPhotoCollectionViewCell: UICollectionViewCell {
   public static let APPhotoCollectionViewCellId = "APPhotoCollectionViewCellId"
    
   @IBOutlet weak var photoImageView: UIImageView!
    
    func configurationWithViewModel(viewModel: APImageViewModel) {

        if let imageUrlString = viewModel.imageUrlPath, let imageUrl = URL(string: imageUrlString) {
            photoImageView.setImageWithURL(imageUrl, placeholderImage: UIImage(named: "imagePlaceholder")!, activityIndicatorStyle: .gray, completion: { (status, image) in
                if !status {
                    self.photoImageView?.image = UIImage(named: "Test")!
                }
            })
        }

    }
    
}
