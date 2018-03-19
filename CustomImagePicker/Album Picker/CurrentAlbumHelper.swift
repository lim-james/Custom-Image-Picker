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
        return currentAlbumIndexPath
    }
    
    // return first image of album
    func getThumbnail(of album: PHCollection) -> UIImage {
        // trying to safely extract first image if present
        // if album is empty return empty image
        // else return first image
        return (gallery[album]?.isEmpty)! ? UIImage() : getUIImage(from: gallery[album]!.first!)!
    }
}
