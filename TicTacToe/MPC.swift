//
//  MPC.swift
//  TicTacToe
//
//  Created by Dwayne Langley on 4/27/17.
//  Copyright © 2017 Dwayne Langley. All rights reserved.
//

import UIKit
import MultipeerConnectivity

var mpcHandler = MPC.handler

class MPC: NSObject {
    static var handler = MPC()
    
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCBrowserViewController!
    var advertiser: MCAdvertiserAssistant?
    var delegate: MPCHandlerDelegate?
    
    override init() {
        super.init()
        setupPeer(with: UIDevice.current.name)
        setupSession()
        advertiseSelf(shouldAdvertise: true)
    }
    
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

protocol MPCHandlerDelegate {
    func changed(state: MCSessionState, of peer: MCPeerID)
    func received(data: Data, from peer: MCPeerID)
}

extension MPC: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        DispatchQueue.main.async {
            self.delegate?.changed(state: state, of: peerID)
        }
    }
    
    /// New callback to handle security and decide whether or not to accept an invitation after hitting the accept button.
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        
        return certificateHandler(true)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        DispatchQueue.main.async {
            self.delegate?.received(data: data, from: peerID)
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
}
