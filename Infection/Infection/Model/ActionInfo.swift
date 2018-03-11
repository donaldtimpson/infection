//
//  ActionInfo.swift
//  Infection
//
//  Created by PJ Vea on 11/10/17.
//  Copyright © 2017 Kraig Wastlund. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import SceneKit

class ActionInfo: MPCSerializable {
    var uuid: UUID!
    var position: CGPoint!
    var velocity: CGVector!
    
    init(uuid: UUID!, position: CGPoint, velocity: CGVector) {
        self.uuid = uuid
        self.position = position
        self.velocity = velocity
    }
    
    var mpcSerialized: Data {
        let dictionary = ["uuid": self.uuid, "position": self.position, "velocity": self.velocity] as [String : Any]
        return NSKeyedArchiver.archivedData(withRootObject: dictionary)
    }
    
    required init(mpcSerialized: Data) {
        let dict = NSKeyedUnarchiver.unarchiveObject(with: mpcSerialized) as! [String: Any]
        self.uuid = dict["uuid"]! as! UUID
        self.position = dict["position"]! as! CGPoint
        self.velocity = dict["velocity"]! as! CGVector
    }
}
