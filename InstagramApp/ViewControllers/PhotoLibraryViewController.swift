//
//  PhotoLibraryViewController.swift
//  InstagramApp
//
//  Created by User on 12/7/19.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import UIKit
import Photos

class PhotoLibraryViewController: UIViewController {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    private var images = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        populatePhotos()
    }
    
    private func populatePhotos() {
        PHPhotoLibrary.requestAuthorization{ [weak self] status in
            if status == .authorized {
                //access the photos from photo library
                let assets = PHAsset.fetchAssets(with: .image, options: nil)
                assets.enumerateObjects { (object, count, stop) in
                    self?.images.append(object)
                    self?.images.reverse()
                    DispatchQueue.main.async {
                        self?.photosCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension PhotoLibraryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCollectionViewCell else  {
            fatalError("CollectionView Cell not found")
        }
        
        let asset = self.images[indexPath.row]
        let manager = PHImageManager.default()
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil) { image, _ in
            DispatchQueue.main.async {
                cell.photoImageView.image = image
            }
        }
        return cell
    }
}

extension PhotoLibraryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width * 0.32
        let height = self.view.frame.height * 0.179910045
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAsset = self.images[indexPath.row]
        PHImageManager.default().requestImage(for: selectedAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: nil) { [weak self] image, info in
            guard let info = info else { return }
            let isDegradedImage = info["PHImageResultIsDegradedKey"] as! Bool
            if !isDegradedImage {
                if let image = image {
                    print(image)
                    NotificationCenter.default.post(name: NSNotification.Name("createPost"), object: image)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
            
        }
    }
}
extension PhotoLibraryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
}
