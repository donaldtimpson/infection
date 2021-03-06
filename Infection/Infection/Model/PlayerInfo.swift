//
//  PlayerInfo.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class PlayerInfo {
    var peerID: MCPeerID!
    var position: CGPoint!
    var isInfected: Bool!
    
    init(peerID: MCPeerID, position: CGPoint, isInfected: Bool) {
        self.peerID = peerID
        self.position = position
        self.isInfected = isInfected
    }
    
    init(message: [String: Any]) {
        self.peerID = message["peerID"]! as! MCPeerID
        self.position = CGPoint(x: message["x"] as! CGFloat, y: message["y"] as! CGFloat)
        self.isInfected = message["isInfected"] as! Bool
    }
    
    func getMessage() -> [String: Any] {
        return ["playerInfo": ["x": self.position.x, "y": self.position.y, "isInfected": self.isInfected]] as [String : Any]
    }
}
