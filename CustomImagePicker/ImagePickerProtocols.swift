//
//  ImagePickerProtocols.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Photos

// allow Album Picker View to communicate with Image Picker View
protocol CurrentAlbumDelegate {
    // setting the current album
    func setCurrent(indexPath: IndexPath)
    // getting the current album
    func getCurrent() -> IndexPath
    // getting thumbnail of specific album
    func getThumbnail(of album: PHCollection) -> UIImage
}
