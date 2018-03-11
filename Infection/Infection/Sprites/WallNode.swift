//
//  WallNode.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import SpriteKit

enum WallOrientation {
    case leftEnd
    case rightEnd
    case topEnd
    case bottomEnd
    case horizantal
    case vertical
    case intersect
    
    func texture() -> SKTexture {
        switch self {
        case .leftEnd : return SKTexture(imageNamed: "w-left-end")
        case .rightEnd : return SKTexture(imageNamed: "w-right-end")
        case .topEnd : return SKTexture(imageNamed: "w-top-end")
        case .bottomEnd : return SKTexture(imageNamed: "w-bottom-end")
        case .vertical : return SKTexture(imageNamed: "w-vertical")
        case .horizantal : return SKTexture(imageNamed: "w-horizantal")
        case .intersect : return SKTexture(imageNamed: "w-intersect")
        }
    }
}

class WallNode: SKSpriteNode {
    
    static let WIDTH = CGFloat(30)
    static let HEIGHT = CGFloat(30)
    
    convenience init(width: CGFloat = WallNode.WIDTH, height: CGFloat = WallNode.WIDTH, orientation: WallOrientation) {
        let texture = orientation.texture()
        
        self.init(texture: texture, color: UIColor.white, size: CGSize(width: width, height: height))
        self.zPosition = 0
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height))
        self.physicsBody?.categoryBitMask = BitMask.wall.rawValue
        self.physicsBody?.collisionBitMask = BitMask.player.rawValue | BitMask.bullet.rawValue
        self.physicsBody?.contactTestBitMask = BitMask.player.rawValue | BitMask.bullet.rawValue
        self.physicsBody?.isDynamic = false
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.restitution = 0
        self.name = "Wall"
        
        self.shadowedBitMask = BitMask.light.rawValue
        self.lightingBitMask = BitMask.light.rawValue
        self.shadowCastBitMask = BitMask.light.rawValue
        
    }
}

