//
//  MPCHandler.swift
//  TicTacToe
//
//  Created by Dwayne Langley on 4/27/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MPCHandler: NSObject {
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCBrowserViewController!
    var advertiser: MCAdvertiserAssistant?
    
    func setupPeer(with displayName: String) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession() {
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func setupBrower() {
        browser = MCBrowserViewController(serviceType: "myGame", session: session)
        
    }
    
    func advertiseSelf(shouldAdvertise:Bool) {
        guard shouldAdvertise else {
            advertiser?.stop()
            advertiser = nil
            return
        }
        
        advertiser = MCAdvertiserAssistant(serviceType: "myGame", discoveryInfo: nil, session: session)
        advertiser?.start()
    }
}

extension MPCHandler: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        let userInfo : [String : Any] = ["peerID": peerID, "state":state.rawValue]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidChangeState_Notification"), object: nil, userInfo: userInfo)
        }
    }
    
    /// New callback to handle security and decide whether or not to accept an invitation after hitting the accept button.
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        
        return certificateHandler(true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let userInfo : [String : Any] = ["peerID": peerID, "data": data]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MPC_DidReceiveData_Notification"), object: nil, userInfo: userInfo)
        }
    }
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
}
