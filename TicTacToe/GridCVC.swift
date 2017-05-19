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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    // Allows the ability to use the selected state of the cell.
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Disables the default ability to unselect a selected cell.
    override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Cell was selected here.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(collectionView.indexPathsForSelectedItems ?? 0)
    }
}

