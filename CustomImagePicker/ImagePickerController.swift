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
    
    // stores the index path of the selected album
    var currentAlbum: IndexPath = .init(row: 0, section: 0)
    
    var images: [UIImage] = []
    
    var selectingMultiple = false // indicates whether use can select multiple images
    var selectedCells: [IndexPath] = [.init(row: 0, section: 0)] // stores cells that have been selected
    // stores the current cell user is on
    var currentCell: IndexPath! {
        // when set refresh preview view
        didSet {
            previewView.image = images[currentCell.row]
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
        
        fetchPhotos()
    }
    
    // fetch photos from user's library
    func fetchPhotos() {
        // request access to photos
        PHPhotoLibrary.requestAuthorization { (status) in
            // check status of reguest
            switch status {
            case .authorized:
                // if authorized, start fetching
                let fetchOptions = PHFetchOptions()
                // fetch all images as photo assets
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                // loop through all photos and add them to images array
                for i in 0..<allPhotos.count {
                    // before appending turn photo assets into uiimage
                    self.images.append(self.getUIImage(from: allPhotos[i]))
                }
                // collection view can only be reloaded on main thread
                DispatchQueue.main.async {
                    // set selected cell to the first item
                    self.currentCell = IndexPath(row: 0, section: 0)
                    // refresh view
                    self.collectionView.reloadData()
                }
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                print("Not determined yet")
            }
        }
    }
    
    // convert photo asset to uiimage
    func getUIImage(from asset: PHAsset) -> UIImage {
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
        return img!
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
            if selectedCells.isEmpty {
                // if no set select cells to current cell
                selectedCells = [currentCell]
            } else {
                // if yes remove all except the first item
                // store the first selected cell
                let first = selectedCells.first!
                // remove all selected cells remove list
                selectedCells.removeAll()
                // adding back the first selected cell
                selectedCells.append(first)
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
        view.albums = 7 // placeholder
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    // setting up main image picker
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath) as! ImageCollectionViewCell
        // check if current cell was selected
        if selectedCells.contains(indexPath) {
            // if yes set index of cell to be index of cells index path in the selected cell list
            cell.index =  selectedCells.index(of: indexPath)
        } else {
            // else set cell index to -1 (explained in image collection view cell file)
            cell.index = -1
        }
        // hide label is not selecting multiple and show if user is selecting multiple
        cell.indexLabel.isHidden = !selectingMultiple
        
        // check if current cell was the cell user is currently selecting
        if indexPath == currentCell {
            // if yes, highlight cell
            cell.alpha = 0.8
        }
        
        // assign image at for this cell to image view
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    // handles event when cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // store indexPath of selected index path
        var selectedCell = indexPath
        
        // check if the user enabled multiple selection to adjust action accordingly
        if selectingMultiple {
            // check if this cell was previously selected
            if selectedCells.contains(selectedCell) {
                // if yes, check if this cell is already selected
                // because user tap once to preview and taps a second time to deselect
                if currentCell == selectedCell {
                    // if yes too, remove selected index path from seleected list
                    selectedCells.remove(at: selectedCells.index(of: selectedCell)!)
                    // check if there're other still other cells
                    if selectedCells.count > 0 {
                        // if yes, change selected cell to the last cell of list
                        selectedCell = selectedCells.last!
                    }
                }
            } else {
                // if no, add selected index path to seleected list
                selectedCells.append(selectedCell)
            }
        } else {
            // set current selected index path to selected list
            selectedCells = [selectedCell]
        }
        
        // set the current cell the user is on to select cell index path
        currentCell = selectedCell
        
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
