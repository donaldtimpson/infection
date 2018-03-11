//
//  MPCAttributedString.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import Foundation

struct MPCAttributedString: MPCSerializable {
    let attributedString: NSAttributedString
    
    var mpcSerialized: Data {
        return NSKeyedArchiver.archivedData(withRootObject: attributedString)
    }
    
    init(attributedString: NSAttributedString) {
        self.attributedString = attributedString
    }
    
    init(mpcSerialized: Data) {
        let attributedString = NSKeyedUnarchiver.unarchiveObject(with: mpcSerialized) as! NSAttributedString
        self.init(attributedString: attributedString)
    }
}
