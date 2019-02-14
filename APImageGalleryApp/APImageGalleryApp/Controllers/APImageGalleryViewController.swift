//
//  APImageGalleryViewController.swift
//  APImageGalleryApp

//  Copyright © 2019 Ranjan. All rights reserved.

import UIKit

let kPadding:CGFloat = 10.0 //Spacing between cells

class APImageGalleryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    var viewModel: APImageViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gallery"
        collectionView.dataSource = self
        collectionView.backgroundView = nil
        collectionView.delegate  = self
        collectionView.backgroundColor = .white
        callFlickerService()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func sortBySelection(_ sender: Any) {
        
        if segmentControl.selectedSegmentIndex == 0 {
            viewModel?.sortByCreationDate()
            collectionView.reloadData()
        }
        else {
            viewModel?.sortByPublishedDate()
            collectionView.reloadData()
        }
        
    }
    
    private func callFlickerService(_ searchtag: String = "") {

        if let url = URL(string: (searchtag.isEmpty) ? URLConfig.endPoint : String(format: URLConfig.searchEndPoint, searchtag)) {
            weak var weakSelf = self
            APImageGalleryService().performRequest(endPointUrl: url, completion: {(model, error) in
                if error != nil {
                    weakSelf?.showServerErrorAlert()
                }
                else {
                    if let items = model?.items {
                        weakSelf?.viewModel = APImageViewModel(results: items)
                        DispatchQueue.main.async {
                            weakSelf?.collectionView.reloadData()
                        }
                    }
                    
                }
            })
        }
        else {
             showAlertWithMessage(message: "Url end point is not correct !!")
        }
        
    }
}

extension APImageGalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.resultCount ?? 0
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: APPhotoCollectionViewCell.APPhotoCollectionViewCellId, for: indexPath) as? APPhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if let viewModel = viewModel {
            viewModel.viewModelForIndex(index: indexPath.row)
            cell.configurationWithViewModel(viewModel: viewModel)
        }
       
        return cell
    }
}


extension APImageGalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView: APSearchCollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: APSearchCollectionReusableView.HeaderCollectionViewId, for: indexPath) as! APSearchCollectionReusableView
            
            return headerView
        }
        
        return UICollectionReusableView()
        
    }
}

extension APImageGalleryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return kPadding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard (viewModel?.results) != nil else {
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: collectionView.frame.size.width/3 - kPadding*1.5 , height: 120)
    }
}


extension APImageGalleryViewController: UISearchBarDelegate {
    
    //MARK: - SEARCH
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            //reload your data source if necessary
            callFlickerService(searchBar.text ?? "")
            collectionView?.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            //reload your data source if necessary
            searchBar.placeholder = "Search By Tags"
            callFlickerService()
            collectionView?.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    
    }
}


extension APImageGalleryViewController: UtilityProtocols {}
