//
//  SessionInfo.swift
//  Infection
//
//  Created by PJ Vea on 11/10/17.
//  Copyright © 2017 Kraig Wastlund. All rights reserved.
//

import UIKit

class SessionInfo: MPCSerializable {
    var uuid: UUID!
    var levelString: String!
    
    init(uuid: UUID!, levelString: String) {
        self.uuid = uuid
        self.levelString = levelString
    }
    
    var mpcSerialized: Data {
        let dictionary = ["uuid": self.uuid, "levelString": self.levelString] as [String : Any]
        return NSKeyedArchiver.archivedData(withRootObject: dictionary)
    }
    
    required init(mpcSerialized: Data) {
        let dict = NSKeyedUnarchiver.unarchiveObject(with: mpcSerialized) as! [String: Any]
        self.uuid = dict["uuid"]! as! UUID
        self.levelString = dict["levelString"]! as! String
    }
}
