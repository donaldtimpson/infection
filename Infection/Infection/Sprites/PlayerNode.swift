//
//  PlayerNode.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

class PlayerNode: SKSpriteNode {
    
    static let SPEED = CGFloat(100)
    static let SIZE = CGSize(width: 20, height: 20)
    static let DASH_DISTANCE = CGFloat(60)
    static let DASH_TIME = TimeInterval(0.1)
    
    var isInfected = false {
        didSet {
            if isInfected {
                self.texture = SKTexture(imageNamed: "zombie")
            }
        }
    }
    
    var peerId: MCPeerID?
    var previousPostition: CGPoint!
    var isDashing = false
    
    convenience init(playerInfo: PlayerInfo?) {
        self.init(imageNamed: "player")
        self.size = PlayerNode.SIZE
        self.zPosition = 5
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2)
        self.physicsBody?.categoryBitMask = BitMask.player.rawValue
        self.physicsBody?.collisionBitMask = BitMask.wall.rawValue | BitMask.bullet.rawValue
        self.physicsBody?.contactTestBitMask = BitMask.wall.rawValue | BitMask.bullet.rawValue | BitMask.player.rawValue
        self.physicsBody?.restitution = 0
        self.physicsBody?.isDynamic = true
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.name = "player"
        
        self.shadowedBitMask = BitMask.light.rawValue
        self.lightingBitMask = BitMask.light.rawValue
        self.shadowCastBitMask = 0
        
        if let info = playerInfo {
            self.peerId = info.peerID
            self.previousPostition = info.position
            self.position = info.position
            self.isInfected = info.isInfected
        }
    }
    
    func setPlayerPosition(position: CGPoint) {
        self.previousPostition = self.position
        self.position = position
    }
    
    func getInfo() -> PlayerInfo {
        return PlayerInfo(peerID: peerId!, position: position, isInfected: isInfected)
    }
    
    func setVelocity(_ velocity: CGVector) {
        if isDashing == false {
            if velocity.dx < 0 {
                self.xScale = -1.0
            } else {
                self.xScale = 1.0
            }
            
            self.physicsBody!.velocity = velocity
        }
    }
    
    func dash() {
        // Only dash if we're moving a direction
        if self.physicsBody!.velocity.length() > 0 {
            self.isDashing = true
            let newPosition: CGPoint
            
            let adjustedX = (self.position.x / 15).rounded() * 15
            let adjustedY = (self.position.y / 15).rounded() * 15
            
            if abs(self.physicsBody!.velocity.dy) > abs(self.physicsBody!.velocity.dx) {
                if self.physicsBody!.velocity.dy > 0 {
                    newPosition = CGPoint(x: adjustedX, y: adjustedY + PlayerNode.DASH_DISTANCE)
                } else {
                    newPosition = CGPoint(x: adjustedX, y: adjustedY - PlayerNode.DASH_DISTANCE)
                }
            } else {
                if self.physicsBody!.velocity.dx > 0 {
                    newPosition = CGPoint(x: adjustedX + PlayerNode.DASH_DISTANCE, y: adjustedY)
                } else {
                    newPosition = CGPoint(x: adjustedX - PlayerNode.DASH_DISTANCE, y: adjustedY)
                }
            }
            
            self.run(SKAction.move(to: newPosition, duration: PlayerNode.DASH_TIME)) {
                self.isDashing = false
            }
        }
    }
}

