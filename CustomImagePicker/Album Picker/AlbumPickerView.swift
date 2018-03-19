//
//  CategoriesPickerView.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Photos

class AlbumPickerView: UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // for getting and setting the current album of image picker controller
    var currentAlbumDelegate: CurrentAlbumDelegate!
    
    // encapsulate get current method to make code readable
    var selectedAlbum: IndexPath! {
        return currentAlbumDelegate.getCurrent()
    }
    
    // to store all albums
    var albums: [PHCollection] = [] {
        didSet {
            albumCollectionView.reloadData()
        }
    }
    
    // collection view to display categories
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // setting up collection view
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        // provide padding on the left
        albumCollectionView.contentInset.left = 20
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = albumCollectionView.dequeueReusableCell(withReuseIdentifier: "Album", for: indexPath) as! AlbumCollectionViewCell
        // check if current cell was selected and assigns an alpha value to the cell.
        // 1 for selected   0.5 for not selected
        cell.alpha = indexPath == currentAlbumDelegate.getCurrent() ? 1 : 0.5
        cell.album = albums[indexPath.row]
        return cell
    }
    
    // handle events when selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // set the index path of selected album to that of the selected cell
        currentAlbumDelegate.setCurrent(indexPath: indexPath)
        // refresh the collection view
        collectionView.reloadData()
    }
    
}
