//
//  GameScene.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import SpriteKit
import GameplayKit

enum BitMask: UInt32 {
    case player = 1
    case wall = 2
    case bullet = 4
    case light = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var players: [PlayerNode] = []
    var player = PlayerNode(playerInfo: nil)
    var cameraSet = false
    var level: Level!
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    convenience init(level: Level, size: CGSize) {
        self.init(size: size)
        self.level = level
        
        for wall in level.walls {
            self.addChild(wall)
        }
        
        for floorNode in level.floor {
            self.addChild(floorNode)
        }
        
        setupGame()
    }
    
    func setupGame() {
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = .black
        
        level.placePlayer(player: player)
        players.append(player)
        self.addChild(player)
        
        for _ in  0..<10 {
            let player = PlayerNode(playerInfo: nil)
            players.append(player)
            level.placePlayer(player: player)
            self.addChild(player)
        }
        
        let randPlayerToInfec = Int(arc4random()) % players.count
        players[randPlayerToInfec].isInfected = true
        
        setupCamera()
    }
    
    func setupCamera() {
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(cameraNode)
        self.camera = cameraNode
        
        let outerGroup = SKAction.group([SKAction.scale(to: 1, duration: 1.0)])
        camera!.run(outerGroup) {
            let group = SKAction.group([SKAction.scale(to: 0.5, duration: 1.0), SKAction.move(to: self.player.position, duration: 1.0)])
            
            self.camera!.run(group, completion: {
                self.cameraSet = true
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case BitMask.bullet.rawValue | BitMask.wall.rawValue:
            let bullet = contact.bodyB.node
            bullet?.removeFromParent()
            
        case BitMask.bullet.rawValue | BitMask.player.rawValue:
            if let hitPlayer = contact.bodyA.node as? PlayerNode {
                if hitPlayer.isInfected {
                    contact.bodyB.node?.removeFromParent()
                    hitPlayer.removeFromParent()
                    level.placePlayer(player: hitPlayer)
                    self.addChild(hitPlayer)
                }
            } else {
                let hitPlayer = contact.bodyB.node as! PlayerNode
                if hitPlayer.isInfected {
                    contact.bodyA.node?.removeFromParent()
                    level.placePlayer(player: hitPlayer)
                }
            }
            
        case BitMask.player.rawValue | BitMask.player.rawValue:
            // if one player is a zombie and other is not: make other zombie
            let playerOne = contact.bodyA.node as! PlayerNode
            let playerTwo = contact.bodyB.node as! PlayerNode
            if playerOne.isInfected {
                playerTwo.isInfected = true
            } else if playerTwo.isInfected {
                playerOne.isInfected = true
            }
            
        default:
            break
        }
    }
}
