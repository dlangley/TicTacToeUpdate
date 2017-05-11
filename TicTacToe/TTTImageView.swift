//
//  tttImageView.swift
//  TicTacToe
//
//  Created by Dwayne Langley on 4/27/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

class TTTImageView: UIImageView {

    var player: String?
    var isActivated = false
    
    func setPlayer(_player: String) {
        guard !isActivated else {
            
            return
        }
        
        player = _player
        
        guard _player == "x" else {
            image = #imageLiteral(resourceName: "o")
            return
        }
        
        image = #imageLiteral(resourceName: "x")
        isActivated = true
    }
}
