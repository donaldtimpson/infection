//
//  MPCHandler.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MPCHandlerDelegate: class {
    func didRecieveLevel(level: Level)
}

enum NotificationName: String {
    case didChangeState = "MPC_DidChangeStateNotification"
    case didReceiveData = "MPC_DidReceiveDataNotification"
    
    func name() -> NSNotification.Name {
        return NSNotification.Name(self.rawValue)
    }
}

class MPCHandler: NSObject, MCSessionDelegate {
    private static let SERVICE_TYPE = "infection"
    
    private static var _defaultHandler: MPCHandler?
    static var defaultHandler: MPCHandler {
        get {
            if _defaultHandler == nil {
                _defaultHandler = MPCHandler()
            }
            
            return _defaultHandler!
        }
    }
    
    weak var delegate: MPCHandlerDelegate?
    var peerID: MCPeerID!
    var session: MCSession!
    var advertiser: MCAdvertiserAssistant? = nil
    lazy var browser: MCBrowserViewController = {
            assert(session != nil, "Failed to set session before getting browser")
            return MCBrowserViewController(serviceType: MPCHandler.SERVICE_TYPE, session: session)
    }()
    
    func start() {
        setupPeerWith(displayName: UIDevice.current.name)
        setupSession()
        startAdvertising()
    }
    
    func setupPeerWith(displayName: String) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession() {
        assert(peerID != nil, "Failed to set peer id before setting up session")
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func startAdvertising() {
        assert(session != nil, "Failed to set session before setting up advertiser")
        advertiser = MCAdvertiserAssistant(serviceType: MPCHandler.SERVICE_TYPE, discoveryInfo: nil, session: session)
        advertiser!.start()
    }
    
    func stop() {
        advertiser?.stop()
        advertiser = nil
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let userInfo: [String: Any] = ["peerID": peerID, "state": state.rawValue]
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NotificationName.didChangeState.name(), object: nil, userInfo: userInfo)
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
        let message = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String, Any>
        
        for (key,value) in message {
            switch key {
            case "level":
                let level = Level(encodedString: value as! String)
                DispatchQueue.main.async { self.delegate?.didRecieveLevel(level: level) }
            default:
                print("NOT HANDLING KEY: \(key)")
            }
        }
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func sendMessage(message: [String: Any]) {
        do {
            let messageData = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
            try self.session.send(messageData, toPeers: self.session.connectedPeers, with: .reliable)
            
        } catch let error {
            print("Failed to get json object: \(error.localizedDescription)")
        }
    }
}
