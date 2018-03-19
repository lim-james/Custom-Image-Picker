//
//  ImageCollectionViewCell.swift
//  CustomImagePicker
//
//  Created by James on 19/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

func bubblify(_ b: UILabel) {
    b.textColor = b.tintColor
    b.clipsToBounds = true
    b.backgroundColor = .clear
    b.layer.cornerRadius = b.frame.height/2
    b.layer.borderWidth = 1
    b.layer.borderColor = b.tintColor.cgColor
}

func bubblify(_ b: UILabel, enabled: Bool) {
    bubblify(b)
    if enabled {
        b.backgroundColor = b.tintColor
        b.textColor = .white
    }
}

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var indexLabel: UILabel!
    
    // stores index of cell
    var index: Int! {
        didSet {
            // check if item was selected
            // -1 represents item is not selected
            if index == -1 {
                // if no, set text ofindex label to be empty
                indexLabel.text = ""
                // bubblify label but set its enabled state to false
                bubblify(indexLabel, enabled: false)
            } else {
                // if yes, set text of index label to be the index assigned
                indexLabel.text = "\(index! + 1)"
                // bubblify label and set its enabled state to true
                bubblify(indexLabel, enabled: true)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .black // placeholder
        
        imageView.contentMode = .scaleAspectFill
    }
}
