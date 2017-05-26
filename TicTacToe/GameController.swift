//
//  GameController.swift
//  TicTacToe
//
//  Created by Dwayne Langley on 5/19/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class GameController: UIViewController {
    
    private let wins = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentPlayer = "x"
    
    var grid : GridCVC!
    
    @IBAction func connectWithPlayer(_ sender: UIBarButtonItem) {
        guard mpcHandler.session != nil else {
            return
        }
        mpcHandler.setupBrower()
        mpcHandler.browser.delegate = self
        present(mpcHandler.browser, animated: true, completion: nil)
    }
    
    @IBAction func newGame(_ sender: UIBarButtonItem) {
        resetGame()
        package(json: ["string":"New Game"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
         
        mpcHandler.delegate = self
        grid = childViewControllers.first as! GridCVC
        grid.delegate = self
    }
    
    /// Checks the possible winning combinations for the last selected square.
    func checkResults(with player: String, at space: Int) {
        for combo in wins where combo.contains(space){
            let spaces = uniqueSpaces(from: combo)
            guard spaces.count > 1 else {
                popUp(message: "\(player) WINS!!!", action: gameOver())
                package(json: ["string": "Gsme Over"])
                break
            }
        }
    }
}

extension GameController: GridDelegate {
    func tapped(space: Int) {
        package(json: ["field": space, "player": currentPlayer])
        checkResults(with: currentPlayer, at: space)
    }
    
    func notify(_ message: String) {
        popUp(message: message, action: ())
    }
}


// MARK: Multipeer Handling
extension GameController: MPCHandlerDelegate {
    
    /// Updates the screen with connection status.
    func changed(state: MCSessionState, of peer: MCPeerID) {
        guard state == .connected else {
            navigationItem.title = "No Connection"
            navigationItem.leftBarButtonItem?.isEnabled = true
            mpcHandler.advertiseSelf(shouldAdvertise: true)
            return
        }
        navigationItem.title = "Connected"
        navigationItem.leftBarButtonItem?.isEnabled = false
        mpcHandler.advertiseSelf(shouldAdvertise: false)
    }
    
    /// Updates screen with other player's actions.
    func received(data: Data, from peer: MCPeerID) {
        var message = unpack(json: data)
        guard message["string"] as? String != "Gsme Over" else {
            popUp(message: "You Lose!!!", action: gameOver())
            return
        }
        guard message["string"] as? String != "New Game" else {
            popUp(message: "New Game!!!", action: resetGame())
            return
        }
        guard let space = message["field"] as? Int, let player = message["player"] as? String else {
            print("Missing message info.")
            return
        }
        
        field(at: space).player = player
        grid.collectionView?.selectItem(at: IndexPath(item: space, section: 0), animated: true, scrollPosition: .top)
        currentPlayer = player == "o" ? "x" : "o"
    }
}

extension GameController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
}

// MARK: Game Environment
extension GameController {
    
    /// Used to disable any further selection so the winner can gloat.
    func gameOver() {
        grid.collectionView?.isUserInteractionEnabled = false
    }
    
    /// Used to reset the game.
    func resetGame() {
        for path in (grid.collectionView?.indexPathsForSelectedItems)! {
            grid.collectionView?.deselectItem(at: path, animated: true)
        }
        grid.collectionView?.isUserInteractionEnabled = true
        currentPlayer = "x"
    }
}

// MARK: Just utility methods for redundant stuff
extension GameController {
    
    /// Normalizes indexes of indexpaths.
    func field(at index: Int) -> FieldCell {
        return grid.collectionView?.cellForItem(at: IndexPath(item: index, section: 0)) as! FieldCell
    }
    
    /// Used in logic for checking 3 in a row.
    func uniqueSpaces(from fieldSet: [Int]) -> Set<String> {
        var spaces = [String]()
        for space in fieldSet {
            guard field(at: space).isSelected else {
                spaces.append("")
                continue
            }
            spaces.append(field(at: space).player)
        }
        return Set(spaces)
    }
    
    /// Used to convert data into native Dictionary object.
    func unpack(json: Data) -> [String: Any] {
        var message = [String: Any]()
        message = try! JSONSerialization.jsonObject(with: json, options: .allowFragments) as! [String : Any]
        return message
    }
    
    /// Creates data object for IoT/net communications and syncs with other player.
    func package(json message: [String : Any]) {
        var messageData : Data
        do {
            messageData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        } catch {
            print("Error packaging message into data.")
            return
        }
        syncPlayers(with: messageData)
    }
    
    /// Sends data objects to other IoT players/devices.
    func syncPlayers(with message: Data) {
        do {
            try mpcHandler.session.send(message, toPeers: mpcHandler.session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending")
        }
    }
    
    /// Pops up a specified alert message and performs associated action.
    func popUp(message: String, action: ()) {
        let alert = UIAlertController(title: "Tic Tac Toe", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:  { (alert) in
            action
        }))
        present(alert, animated: true, completion: nil)
    }
}
