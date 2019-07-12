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
    
}
extension PhotoLibraryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
}
