//
//  ImagePickerProtocols.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

// allow Album Picker View to communicate with Image Picker View
protocol CurrentAlbumDelegate {
    // setting the current album
    func setCurrent(indexPath: IndexPath)
    // getting the current album
    func getCurrent() -> IndexPath
}
