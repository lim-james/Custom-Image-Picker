//
//  CurrentAlbumHelper.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

// encapsulating Current Album Delegate methods
extension ImagePickerController: CurrentAlbumDelegate {
    // set current album to arguments passed through
    func setCurrent(album: IndexPath) {
        currentAlbum = album
    }
    
    // return value of current album
    func getCurrent() -> IndexPath {
        return currentAlbum
    }
}
