//
//  ViewController.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

class ImagePickerController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // declaration of variables
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var multipleButton: UIButton!
    
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // stores the index path of the selected album
    var currentAlbum: IndexPath = .init(row: 0, section: 0)
    
    var selectingMultiple = false // indicates whether use can select multiple images
    var selectedCells: [IndexPath] = [] // stores cells that have been selected
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting up collection view
        collectionView.delegate = self
        collectionView.dataSource = self
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
            // if yes remove all except the first item
            // store the first selected cell
            let first = selectedCells.first!
            // remove all selected cells remove list
            selectedCells.removeAll()
            // adding back the first selected cell
            selectedCells.append(first)
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
        return 10 // placeholder
    }
    
    // setting up main image picker
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image", for: indexPath)
        // placeholder
        // check if current cell was selected and change the background color of the cell accordingly
        // light gray is yes    white is not
        cell.backgroundColor = selectedCells.contains(indexPath) ? .lightGray : .white
        return cell
    }
    
    // handles event when cell is selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // check if the user enabled multiple selection to adjust action accordingly
        if selectingMultiple {
            // check if this cell was previously selected
            if selectedCells.contains(indexPath) {
                // if yes, remove selected index path from seleected list
                selectedCells.remove(at: selectedCells.index(of: indexPath)!)
            } else {
                // if no, add selected index path to seleected list
                selectedCells.append(indexPath)
            }
        } else {
            // check if this cell was previously selected
            if selectedCells.contains(indexPath) {
                // if yes, remove selected index path from seleected list
                selectedCells = []
            } else {
                // if no, set current selected index path to selected list
                selectedCells = [indexPath]
            }
        }
        // refresh view
        collectionView.reloadData()
    }
}