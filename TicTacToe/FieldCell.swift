//
//  FieldCell.swift
//  TicTacToe
//
//  Created by Dwayne Langley on 5/16/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

class FieldCell: UICollectionViewCell {
    
    private var imageView = UIImageView()
    
    var player = "x"
    
    override var isSelected: Bool {
        willSet {
            imageView.image = player == "x" ? #imageLiteral(resourceName: "x") : #imageLiteral(resourceName: "o")
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        imageView.contentMode = .center
        selectedBackgroundView = imageView
    }
}
