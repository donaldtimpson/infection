//
//  FloorNode.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit

import SpriteKit

class FloorNode: SKSpriteNode {
    
    static let WIDTH = CGFloat(30)
    static let HEIGHT = CGFloat(30)
    
    convenience init(width: CGFloat = FloorNode.WIDTH, height: CGFloat = FloorNode.WIDTH) {
        self.init(texture: SKTexture(imageNamed: "floor-tile"), color: UIColor.white, size: CGSize(width: width, height: height))
        self.zPosition = -5
        self.name = "Floor"
    }
}
