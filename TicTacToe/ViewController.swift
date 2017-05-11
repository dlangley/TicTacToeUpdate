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
        emptyFields()
        
        let messageDict = ["string":"New Game"]
        var messageData : Data
        var error: NSError?
        do {
            messageData = try JSONSerialization.data(withJSONObject: messageDict, options: .prettyPrinted)
        } catch {
            print("Error")
            return
        }
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appDelegate.mpcHandler.setupPeer(with: UIDevice.current.name)
        appDelegate.mpcHandler.setupSession()
        appDelegate.mpcHandler.advertiseSelf(shouldAdvertise: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.peerChangedState(with:)), name: NSNotification.Name.init(rawValue: "MPC_DidChangeStateNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleReceivedData(with:)), name: NSNotification.Name.init(rawValue: "MPC_DidReceiveData_Notification"), object: nil)
        
        setupFields()
        currentPlayer = "x"
    }
    
    func peerChangedState(with notification: Notification) {
        
        guard let userInfo = notification.userInfo else {
            print("No userInfo")
            return
        }
        guard let state = userInfo["state"] as? Int else {
            print("Bad State")
            return
        }
        guard state != MCSessionState.connecting.rawValue else {
            print("State is \(String(describing: MCSessionState(rawValue: state)))")
            return
        }
        navigationItem.title = "Connected"
        
    }
    
    func handleReceivedData(with notification: Notification) {
        
        guard let userInfo = notification.userInfo else {
            print("No Info Received")
            return
        }
        
        guard let receivedData = userInfo["data"] as? Data else {
            print("Data conversion issue")
            return
        }
        
        let senderID = userInfo["peerID"] as! MCPeerID
        let senderName = senderID.displayName
        var message = [String: Any]()
        
        do {
            message = try! JSONSerialization.jsonObject(with: receivedData, options: .allowFragments) as! [String : Any]
        } catch {
            print("error parsing message")
        }
        
        guard String(describing: message["string"]) != "New Game" else {
            let alert = UIAlertController(title: "Tic Tac Toe", message: "New Game!!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.emptyFields()
            }))
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let space = message["field"] as? Int, let player = message["player"] as? String else {
            print("Missing message info.")
            return
        }
        fields[space].setPlayer(_player: player)
        currentPlayer = player == "o" ? "x" : "o"
        
        checkResults(with: player, at: space)
    }
    
    func checkResults(with player: String, at space: Int) {
        var winner = false
        let wins = [[0,1,2], [3,4,5], [6,7,8], [0,3,6], [1,4,7], [2,5,8], [0,4,8], [2,4,6]]
        
        for fieldSet in wins where fieldSet.contains(space){
            var spaces = Set<String>()
            
            for field in fieldSet {
                guard let spaceMark = fields[field].player else {
                    return
                }
                
                spaces.insert(spaceMark)
            }
            
            winner = spaces.count <= 1
            
        }
        
        if winner {
            let alert = UIAlertController(title: "Tic Tac Toe", message: "\(player) WINS!!!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self.emptyFields()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func setupFields() {
        for index in 0 ..< fields.count {
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.fieldTapped(recognizer:)))
            gestureRecognizer.numberOfTapsRequired = 1
            fields[index].addGestureRecognizer(gestureRecognizer)
        }
    }
    
    func emptyFields() {
        for index in 0 ..< fields.count {
            fields[index].player = ""
            fields[index].image = nil
            fields[index].isActivated = false
        }
        
        currentPlayer = "x"
    }
    
    func fieldTapped(recognizer: UITapGestureRecognizer) {
        let tappedField = recognizer.view as! TTTImageView
        tappedField.setPlayer(_player: currentPlayer)
        
        let messageDict : [String : Any] = ["field": tappedField.tag, "player": currentPlayer]
        var messageData : Data
        var error: NSError?
        do {
            messageData = try JSONSerialization.data(withJSONObject: messageDict, options: .prettyPrinted)
        } catch {
            print("Error")
            return
        }
        do {
            try appDelegate.mpcHandler.session.send(messageData, toPeers: appDelegate.mpcHandler.session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending")
        }
        
        checkResults(with: currentPlayer, at: tappedField.tag)
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

