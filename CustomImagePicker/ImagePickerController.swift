//
//  ViewController.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Photos
import CoreGraphics

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
    
    let requestOptions = PHImageRequestOptions()
    // for caching of images
    let cachingImageManager = PHCachingImageManager()
    
    // store gallery from device
    var gallery: [PHCollection: [PHAsset]] = [:] {
        willSet {
            // stop caching before assigning
            cachingImageManager.stopCachingImagesForAllAssets()
        }
        
        didSet {
            // start caching with options
            cachingImageManager.startCachingImages(for: photos, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: self.requestOptions)
        }
    }
    
    // gets only albums from gallery
    var albums: [PHCollection] {
        // filter out empty albums
        return Array(gallery.keys).filter({ (album) -> Bool in
            return gallery[album]!.count != 0
        }).sorted(by: { (before, after) -> Bool in
            return (gallery[before]?.count)! > (gallery[after]?.count)!
        })
        
    }
    
    // stores the current selected album
    var currentAlbum: PHCollection! {
        // when set refresh collecitonview in main thread7
        didSet {
            DispatchQueue.main.async {
                self.title = self.currentAlbum.localizedTitle
                if self.collectionView != nil {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    // stores the index path of the selected album
    var currentAlbumIndexPath: IndexPath = .init(row: 0, section: 0) {
        didSet {
            // when did set current album accordingly
            currentAlbum = albums[currentAlbumIndexPath.row]
            // check if photos has at least more than one
            if photos.count <= 1 {
                // if no, fetch photos from current album
                fetchPhotos(from: currentAlbum as! PHAssetCollection)
            }
            // and set current image to first image
            currentPhoto = photos.first
        }
    }
    
    // gets only photos from the current album
    var photos: [PHAsset] {
        // check current album has been initialised
        return currentAlbum != nil ? gallery[currentAlbum]! : []
    }
    
    var selectingMultiple = false // indicates whether use can select multiple images
    var selectedPhotos: [PHAsset] = [] // stores photo that have been selected
    // stores the current photo user is on
    var currentPhoto: PHAsset! {
        // when set refresh preview view
        didSet {
            // check whether preview view has been initialised
            if previewView != nil {
                previewView.image = currentPhoto != nil ? getUIImage(from: currentPhoto) : UIImage()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting up collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // setting up preview view
        previewView.backgroundColor = .black
        previewView.contentMode = .scaleAspectFill
        
        // attempting to call these before hand
        setup()
        fetchSmartAlbums()
    }
    
    // basic set up function
    func setup() {
        // setting options for request
        requestOptions.resizeMode = .fast
        requestOptions.version = .current
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isSynchronous = false
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
                        // get thumbnail for item
                        self.fetchThumbnail(of: allSmartAlbums[i])
                    }
                }
                // start fetching others
                for album in self.albums {
                    // fetch from album
                    self.fetchPhotos(from: album as! PHAssetCollection)
                }
                // collection view can only be reloaded on main thread
                DispatchQueue.main.async {
                    // set current to first (which is camera roll)
                    self.setCurrent(indexPath: IndexPath(row: 0, section: 0))
                    // refresh view if collection view has been initialized
                    if self.collectionView != nil {
                        self.collectionView.reloadData()
                    }
                    
                }
            //                self.fetchAlbums() left out for now
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
            // refresh view if collection view has been initialized
            if self.collectionView != nil {
                self.collectionView.reloadData()
            }
        }
    }
    
    func fetchThumbnail(of album: PHAssetCollection) {
        let fetchOptions = PHFetchOptions()
        // set sorting options for fetch to get earlier images
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        // fetch only first image as photo assets
        fetchOptions.fetchLimit = 1
        let photo = PHAsset.fetchAssets(in: album, options: fetchOptions)
        
        // trying to safely extract first image if present
        // check if photo present
        if photo.count != 0 {
            // if yes, check if photo has already been added
            if !photos.contains(photo.firstObject!) {
                // if no, add to album
                gallery[album]?.append(photo.firstObject!)
            }
        }
    }
    
    // fetch photos from user's library
    func fetchPhotos(from collection: PHAssetCollection) {
        // empty array first
        gallery[collection]?.removeAll()
        let fetchOptions = PHFetchOptions()
        // set sorting options for fetch to get earlier images
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        // fetch all images as photo assets
        let allAssets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
        // loop through all assets and add them to images array
        for i in 0..<allAssets.count {
            // append it to array under collection in albums dictionary
            if !photos.contains(allAssets[i]) {
                gallery[collection]!.append(allAssets[i])
            }
        }
        // collection view can only be reloaded on main thread
        DispatchQueue.main.async {
            // set selected image to the first item
            self.currentPhoto = self.photos.first
            // refresh view if collection view has been initialized
            if self.collectionView != nil {
                self.collectionView.reloadData()
            }
        }
    }
    
    // convert photo asset to full res UIImage
    func getUIImage(from asset: PHAsset) -> UIImage? {
        var img: UIImage?
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.resizeMode = .exact
        options.isSynchronous = true
        
        // get image data from aset
        PHImageManager().requestImageData(for: asset, options: options) { (data, _, _, _) in
            if let data = data {
                img = UIImage(data: data)
            }
        }
        
        // resize image before showing
        return img
    }
    
    // convert photo asset to UIImage with specified size
    func getUIImage(from asset: PHAsset, with size: CGSize) -> UIImage? {
        var img: UIImage?
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .current
        options.resizeMode = .exact
        options.isSynchronous = true
        
        // get image from asset
        PHImageManager().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: options) { (image, _) in
            img = image
        }
        
        // resize image before showing
        return img
    }
    
    // closes this controller
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
            if selectedPhotos.isEmpty {
                // if no set select cells to current cell
                selectedPhotos = [currentPhoto]
            } else {
                // if yes remove all except the first item
                // store the first selected cell
                let first = selectedPhotos.first!
                // remove all selected cells remove list
                selectedPhotos.removeAll()
                // adding back the first selected cell
                selectedPhotos.append(first)
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
        // check if current asset was selected
        let photo = photos[indexPath.row]
        if selectedPhotos.contains(photos[indexPath.row]) {
            // if yes set index of cell to be index of photo index path in the selected cell list
            cell.index = selectedPhotos.index(of: photo)
        } else {
            // else set cell index to -1 (explained in image collection view cell file)
            cell.index = -1
        }
        // hide label is not selecting multiple and show if user is selecting multiple
        cell.indexLabel.isHidden = !selectingMultiple
        
        // check if current photo was the cell user is currently selecting
        if photo == currentPhoto {
            // if yes, highlight cell
            cell.alpha = 0.5
        }
        
        // rasterize
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        // assign image at for this cell to image view
        cell.imageView.image = self.getUIImage(from: self.photos[indexPath.row], with: cell.frame.size)
        return cell
    }
    
    // handles event when cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // store image at selected index path
        var selectedPhoto = photos[indexPath.row]
        
        // check if the user enabled multiple selection to adjust action accordingly
        if selectingMultiple {
            // check if this photo was previously selected
            if selectedPhotos.contains(selectedPhoto) {
                // if yes, check if this photo is already selected
                // because user tap once to preview and taps a second time to deselect
                if currentPhoto == selectedPhoto {
                    // if yes too, remove selected photo from seleected list
                    selectedPhotos.remove(at: selectedPhotos.index(of: selectedPhoto)!)
                    // go through selected photo array
                    for photo in selectedPhotos {
                        // check if current photo is in the same album
                        if photos.contains(photo) {
                            // if yes, change selected image to this photo
                            // else stick don't change
                            selectedPhoto = photo
                        }
                    }
                }
            } else {
                // if no, add selected photo to seleected list
                selectedPhotos.append(selectedPhoto)
            }
        } else {
            // set current selected photo to selected list
            selectedPhotos = [selectedPhoto]
        }
        
        // set the current photo the user is on to select photo index path
        currentPhoto = selectedPhoto
        
        // refresh view
        DispatchQueue.main.async {
            collectionView.reloadData()
        }
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

