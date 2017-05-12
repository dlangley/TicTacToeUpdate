//
//  tttImageView.swift
//  TicTacToe
//
//  Created by Dwayne Langley on 4/27/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

class TTTImageView: UIImageView {

    var player: String? {
        didSet {
            isAvailable = false
        }
    }
    
    var isAvailable = true {
        willSet {
            guard newValue == false else {
                player = ""
                image = nil
                return
            }
            image = player! == "x" ? #imageLiteral(resourceName: "x") : #imageLiteral(resourceName: "o")
        }
    }
    
    
    func setPlayer(_player: String) {
        player = _player
    }
    
    func reset() {
        player = ""
        isAvailable = true
    }
}
