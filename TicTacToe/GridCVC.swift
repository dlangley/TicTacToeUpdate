//
//  GridCVC.swift
//  TicTacToe
//
//  Created by Dwayne Langley on 5/16/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit

private let reuseIdentifier = "fieldCell"

class GridCVC: UICollectionViewController {
    
    var delegate : GridDelegate?
    
    /// Space between cells; real value to be set in IB.
    @IBInspectable var padding: CGFloat = 0
    
    /// Cells per row; real value to be set in IB.
    @IBInspectable var columns: CGFloat = 1
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = (collectionView!.frame.width - (padding * (columns + 1))) / columns
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        collectionView?.allowsMultipleSelection = true
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FieldCell
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    // Allows the ability to use the selected state of the cell.
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        (collectionView.cellForItem(at: indexPath) as! FieldCell).player = (delegate?.currentPlayer)!
        return true
    }
    
    // Disables the default ability to unselect a selected cell.
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        delegate?.notify("Can't touch this!!!")
        return false
    }
    
    // Cell was selected here.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.tapped(space: indexPath.item)
    }
}

protocol GridDelegate {
    var currentPlayer: String { get set }
    func tapped(space: Int)
    func notify(_ message: String)
}
