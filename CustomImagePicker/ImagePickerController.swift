//
//  ViewController.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Photos

class ImagePickerController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // getting view width
    var width: CGFloat! {
        return view.frame.width
    }
    
    // get dynamic spacing between cells
    var cellSpacing: CGFloat! {
        // to hold spacing
        var spacing: CGFloat!
        for i in 0...3 {
            // to test if width - i is a multiple of 4
            if (view.frame.width - CGFloat(i)).truncatingRemainder(dividingBy: 4) == 0 {
                // if yes assign it to spacing
                spacing = CGFloat(i)
                // end because this is the only option
                break
            }
        }
        return spacing
    }
    
    // declaration of variables
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var multipleButton: UIButton!
    
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // store gallery from device
    var gallery: [PHCollection: [UIImage]] = [:]
    
    // gets only albums from gallery
    var albums: [PHCollection] {
        return Array(gallery.keys)
    }
    
    // stores the current selected album
    var currentAlbum: PHCollection! {
        // when set refresh collecitonview
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    // stores the index path of the selected album
    var currentAlbumIndexPath: IndexPath = .init(row: 0, section: 0) {
        didSet {
            // when did set current album accordingly
            currentAlbum = albums[currentAlbumIndexPath.row]
            // and set current image to first image
            currentImage = photos.first
        }
    }
    
    // gets only photos from the current album
    var photos: [UIImage] {
        return gallery[currentAlbum]!
    }
    
    var selectingMultiple = false // indicates whether use can select multiple images
    var selectedImages: [UIImage] = [] // stores cells that have been selected
    // stores the current cell user is on
    var currentImage: UIImage! {
        // when set refresh preview view
        didSet {
            previewView.image = currentImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting up collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // setting up preview view
        previewView.backgroundColor = .black // placeholder
        previewView.contentMode = .scaleAspectFill
        
        fetchSmartAlbums()
    }
    
    // fetch smart albums from user's library
    func fetchSmartAlbums() {
        // request access to photos
        PHPhotoLibrary.requestAuthorization { (status) in
            // check status of reguest
            switch status {
            case .authorized:
                // if authorized, start fetching
                let fetchOptions = PHFetchOptions()
                // fetch all smart albums
                let allSmartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: fetchOptions)
                // assign current album to first album fetched
                self.currentAlbum = allSmartAlbums.firstObject
                // loop through all smart albums and add them to smart albums array
                for i in 0..<allSmartAlbums.count {
                    // check if collection is empty
                    if allSmartAlbums[i].estimatedAssetCount != 0 {
                        // if not empty, create key for albums dictionary
                        self.gallery[allSmartAlbums[i]] = []
                        // fetch photo for this album
                        self.fetchPhotos(from: allSmartAlbums[i])
                    }
                }
                // collection view can only be reloaded on main thread
                DispatchQueue.main.async {
                    // refresh view
                    self.collectionView.reloadData()
                }
                self.fetchAlbums()
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
    }
    
    // fetch albums from user's library
    func fetchAlbums() {
        let fetchOptions = PHFetchOptions()
        // fetch all albums
        let allAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        // loop through all albums and add them to albums array
        for i in 0..<allAlbums.count {
            // check if collection is empty
            if allAlbums[i].estimatedAssetCount != 0 {
                // if not empty, create key for albums dictionary
                gallery[allAlbums[i]] = []
                // fetch photo for this album
                fetchPhotos(from: allAlbums[i])
            }
        }
        // collection view can only be reloaded on main thread
        DispatchQueue.main.async {
            // refresh view
            self.collectionView.reloadData()
        }
    }
    
    // fetch photos from user's library
    func fetchPhotos(from collection: PHAssetCollection) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 50
        // fetch all images as photo assets
        let allAssets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        // loop through all assets and add them to images array
        for i in 0..<allAssets.count {
            // before appending to array, safely convert asset to image
            if let image = getUIImage(from: allAssets[i]) {
                // append it to array under collection in albums dictionary
                gallery[collection]!.append(image)
            }
        }
        // collection view can only be reloaded on main thread
        DispatchQueue.main.async {
            // set selected image to the first item
            self.currentImage = self.photos.first
            // refresh view
            self.collectionView.reloadData()
        }
    }
    
    // convert photo asset to uiimage
    func getUIImage(from asset: PHAsset) -> UIImage? {
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: asset, options: options) { data, _, _, _ in
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img
    }
    
    // closes this controller
    @IBAction func cancelAction(_ sender: Any) {
    }
    
    // closes this controller and sends images to destination controller
    @IBAction func nextAction(_ sender: Any) {
    }
    
    // enables user to select multiple images
    @IBAction func multipleAction(_ sender: Any) {
        // inverse the boolean
        selectingMultiple = !selectingMultiple
        // checking if user disabled selecting multiple
        if !selectingMultiple {
            // if yes, check if there are selected cells
            if selectedImages.isEmpty {
                // if no set select cells to current cell
                selectedImages = [currentImage]
            } else {
                // if yes remove all except the first item
                // store the first selected cell
                let first = selectedImages.first!
                // remove all selected cells remove list
                selectedImages.removeAll()
                // adding back the first selected cell
                selectedImages.append(first)
            }
        }
        // refresh view
        collectionView.reloadData()
    }
    
    // setting up header of collection view (catergories picker)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! AlbumPickerView
        // passing delegate methods to album picker view
        view.currentAlbumDelegate = self
        view.albums = albums
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // check if albums have been added.
        // if no albums present, return 0
        // else return number of images.
        return albums.count == 0 ? 0 : photos.count
    }
    
    // setting up main image picker
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as! ImageCollectionViewCell
        // check if current cell was selected
        let photo = photos[indexPath.row]
        if selectedImages.contains(photos[indexPath.row]) {
            // if yes set index of cell to be index of cells index path in the selected cell list
            cell.index = selectedImages.index(of: photo)
        } else {
            // else set cell index to -1 (explained in image collection view cell file)
            cell.index = -1
        }
        // hide label is not selecting multiple and show if user is selecting multiple
        cell.indexLabel.isHidden = !selectingMultiple
        
        // check if current cell was the cell user is currently selecting
        if photo == currentImage {
            // if yes, highlight cell
            cell.alpha = 0.7
        }
        
        // assign image at for this cell to image view
        cell.imageView.image = photos[indexPath.row]
        return cell
    }
    
    // handles event when cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // store image at selected index path
        var selectedImage = photos[indexPath.row]
        
        // check if the user enabled multiple selection to adjust action accordingly
        if selectingMultiple {
            // check if this image was previously selected
            if selectedImages.contains(selectedImage) {
                // if yes, check if this image is already selected
                // because user tap once to preview and taps a second time to deselect
                if currentImage == selectedImage {
                    // if yes too, remove selected image from seleected list
                    selectedImages.remove(at: selectedImages.index(of: selectedImage)!)
                    // needs to be fixed
                    // check if there're other still other images
                    if selectedImages.count > 0 {
                        // if yes, change selected image to the last image of list
                        selectedImage = selectedImages.last!
                    }
                }
            } else {
                // if no, add selected image to seleected list
                selectedImages.append(selectedImage)
            }
        } else {
            // set current selected image to selected list
            selectedImages = [selectedImage]
        }
        
        // set the current image the user is on to select image index path
        currentImage = selectedImage
        
        // refresh view
        collectionView.reloadData()
    }
    
    // dynamically change cell size based on device size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (width - cellSpacing)/4, height: (width - cellSpacing)/4)
    }
    
    // dynamically change cell spacing based on device size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing/3 // divided by 3 since there're 3 spaces
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing/3 // just to keep things equally spaced
    }
}
