//
//  BulletInfo.swift
//  Infection
//
//  Created by Donald Timpson on 3/11/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class BulletInfo {
    var peerID: MCPeerID!
    var position: CGPoint!
    var velocity: CGVector!
    
    init(peerID: MCPeerID, position: CGPoint, velocity: CGVector) {
        self.peerID = peerID
        self.position = position
        self.velocity = velocity
    }
    
    init(message: [String: Any]) {
        self.peerID = message["peerID"]! as! MCPeerID
        self.position = CGPoint(x: message["x"] as! CGFloat, y: message["y"] as! CGFloat)
        self.velocity = CGVector(dx: message["dx"] as! CGFloat, dy: message["dy"] as! CGFloat)
    }
    
    func getMessage() -> [String: Any] {
        return ["bulletInfo": ["x": position.x, "y": position.y, "dx": velocity.dx, "dy": velocity.dy]] as [String : Any]
    }
}
