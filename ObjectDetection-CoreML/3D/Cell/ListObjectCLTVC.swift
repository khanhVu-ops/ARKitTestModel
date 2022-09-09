//
//  ListObjectCLTVC.swift
//  ObjectDetection-CoreML
//
//  Created by BHSoft on 07/09/2022.
//  Copyright © 2022 tucan9389. All rights reserved.
//

import UIKit

class ListObjectCLTVC: UICollectionViewCell {

    @IBOutlet weak var imgObject2D: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func configure(object: ObjectModel) {
        imgObject2D.image = UIImage(named: object.image2DName)
        lbTitle.text = object.title
    }
}
