
//
//  AlbumCollectionViewCell.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    // initial set up
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.backgroundColor = .black // placeholder
        // making image view a rounded rectangle
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
    }
}
