//
//  BulletNode.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit

import SpriteKit

class BulletNode: SKSpriteNode {
    
    static let SIZE = CGSize(width: 5, height: 5)
    static let SPEED = CGFloat(200)
    
    convenience init() {
        let texture = SKTexture(imageNamed: "ninja-star")
        
        self.init(texture: texture, color: UIColor.white, size: BulletNode.SIZE)
        self.zPosition = 5
        self.physicsBody = SKPhysicsBody(circleOfRadius: CGFloat(1))
        self.physicsBody?.categoryBitMask = BitMask.bullet.rawValue
        self.physicsBody?.collisionBitMask = BitMask.wall.rawValue | BitMask.player.rawValue
        self.physicsBody?.contactTestBitMask = BitMask.wall.rawValue | BitMask.player.rawValue
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.name = "Bullet"
        self.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0)))
    }
}
