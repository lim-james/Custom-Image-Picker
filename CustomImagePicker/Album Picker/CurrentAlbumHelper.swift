//
//  CurrentAlbumHelper.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Photos

// encapsulating Current Album Delegate methods
extension ImagePickerController: CurrentAlbumDelegate {
    // set current album to arguments passed through
    func setCurrent(indexPath: IndexPath) {
        currentAlbumIndexPath = indexPath
    }
    
    // return value of current album
    func getCurrent() -> IndexPath {
        return IndexPath(row: albums.index(of: currentAlbum)!, section: 0)
    }
    
    // return first image of album
    func getThumbnail(of album: PHCollection) -> UIImage {
        let fetchOptions = PHFetchOptions()
        // set sorting options for fetch to get earlier images
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.fetchLimit = 1
        // fetch all images as photo assets
        let photo = PHAsset.fetchAssets(in: album as! PHAssetCollection, options: fetchOptions)
        
        // trying to safely extract first image if present
        // if album is empty return empty image
        // else return first image
        return photo.count == 0 ? UIImage() : getUIImage(from: photo.firstObject!)!
    }
}
