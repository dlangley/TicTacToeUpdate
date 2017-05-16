//
//  ViewController.swift
//  TicTacToe
//
//  Created by Dwayne Langley on 4/26/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentPlayer: String!

    @IBOutlet var fields: [TTTImageView]!
    
    @IBAction func connectWithPlayer(_ sender: UIBarButtonItem) {
        guard appDelegate.mpcHandler.session != nil else {

            return
        }
        appDelegate.mpcHandler.setupBrower()
        appDelegate.mpcHandler.browser.delegate = self
        present(appDelegate.mpcHandler.browser, animated: true, completion: nil)
        
    }
    
    @IBAction func newGame(_ sender: UIBarButtonItem) {
        resetGame()
        package(json: ["string":"New Game"])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate.mpcHandler.setupPeer(with: UIDevice.current.name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(shouldAdvertise: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.peerChangedState(with:)), name: NSNotification.Name.init(rawValue: "MPC_DidChangeState_Notification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleReceivedData(with:)), name: NSNotification.Name.init(rawValue: "MPC_DidReceiveData_Notification"), object: nil)
        
        setupFields()
        currentPlayer = "x"
    }
    
    func checkResults(with player: String, at space: Int) {
        let wins = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        for combo in wins where combo.contains(space){
            let spaces = uniqueSpaces(from: combo)
            guard spaces.count > 1 else {
                popUp(message: "\(player) WINS!!!", action: gameOver())
                package(json: ["string": "Gsme Over"])
                break
            }
        }
    }
    
    func fieldTapped(recognizer: UITapGestureRecognizer) {
        let tappedField = recognizer.view as! TTTImageView
        guard tappedField.isAvailable else {
            print("Field already selected, no action taken.")
            return
        }
        tappedField.setPlayer(_player: currentPlayer)
        package(json: ["field": tappedField.tag, "player": currentPlayer])
        checkResults(with: currentPlayer, at: tappedField.tag)
    }
}


// MARK: Multipeer Handling
extension ViewController {
    
    /// Updates the screen with connection status.
    func peerChangedState(with notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("No userInfo")
            return
        }
        guard let state = userInfo["state"] as? Int else {
            print("Bad State")
            return
        }
        guard state == MCSessionState.connected.rawValue else {
            print("State is \(String(describing: MCSessionState(rawValue: state)))")
            return
        }
        navigationItem.title = "Connected"
    }
    
    /// Updates screen with other player's actions.
    func handleReceivedData(with notification: Notification) {
        guard let userInfo = notification.userInfo else {
            print("No Info Received")
            return
        }
        guard let receivedData = userInfo["data"] as? Data, let senderID = userInfo["peerID"] as? MCPeerID else {
            print("Data conversion issue")
            return
        }
        let senderName = senderID.displayName
        var message = unpack(json: receivedData)        
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
        fields[space].setPlayer(_player: player)
        currentPlayer = player == "o" ? "x" : "o"
    }
}

extension ViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        appDelegate.mpcHandler.browser.dismiss(animated: true, completion: nil)
    }
}

// MARK: Game Environment
extension ViewController {
    
    /// Used to disable any further selection so the winner can gloat.
    func gameOver() {
        for index in 0 ..< fields.count {
            fields[index].isUserInteractionEnabled = false
        }
    }
    
    /// Used to reset the game.
    func resetGame() {
        for index in 0 ..< fields.count {
            fields[index].reset()
            fields[index].isUserInteractionEnabled = true
        }
        currentPlayer = "x"
    }
    
    // TODO: Use collectionView instead of manually implementing a collection of views.
    /// Used to manually create buttons for the game.
    func setupFields() {
        for index in 0 ..< fields.count {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.fieldTapped(recognizer:)))
            gestureRecognizer.numberOfTapsRequired = 1
            fields[index].addGestureRecognizer(gestureRecognizer)
        }
    }
}

// MARK: Just utility methods for redundant stuff
extension ViewController {
    
    /// Used in logic for checking 3 in a row.
    func uniqueSpaces(from fieldSet: [Int]) -> Set<String> {
        var spaces = [String]()
        for field in fieldSet {
            spaces.append(fields[field].player ?? "")
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
            try appDelegate.mpcHandler.session.send(message, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: .reliable)
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
