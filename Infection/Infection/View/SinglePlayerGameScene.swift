//
//  SinglePlayerGameScene.swift
//  Infection
//
//  Created by Donald Timpson on 1/22/18.
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

class SinglePlayerGameScene: SKScene, SKPhysicsContactDelegate {
    
    let TIME_TILL_ZOMBIES_MOVE = 5.0
    let TIME_TILL_ZOMBIE_ADDED = 5
    
    weak var parentController: UIViewController?
    var playerHeader: PlayerHeaderView!
    var joystick = Joystick()
    var dashButton = DashButton()
    var players: [PlayerNode] = []
    var player = PlayerNode(playerInfo: nil)
    var cameraSet = false
    var level: Level!
    var startTime: TimeInterval?
    
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
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            player.isInfected = true
            self.addChild(player)
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupCamera()
    }
    
    func setupCamera() {
        let cameraNode = SKCameraNode()
        cameraNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        playerHeader = PlayerHeaderView(width: self.view!.frame.width, height: self.view!.frame.height)
        joystick.position = CGPoint(x: -self.view!.frame.width/2 + 60, y: -self.view!.frame.height/2 + 60)
        dashButton.position = CGPoint(x: self.view!.frame.width/2 - 60, y: -self.view!.frame.height/2 + 60)
        
        cameraNode.addChild(playerHeader)
        cameraNode.addChild(joystick)
        cameraNode.addChild(dashButton)
        
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
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystick.moveJoyStick(touch: touches.first!)
        joystick.joystickAction = { (offset: CGPoint) in
            self.player.setVelocity(CGVector(dx: offset.x * PlayerNode.SPEED, dy: offset.y * PlayerNode.SPEED))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first, touches.count == 1 {
            if self.playerHeader.backButton.position.distance(to: touch.location(in: self.playerHeader)) < 30 {
                parentController?.dismiss(animated: true, completion: nil)
            }
            
            if !player.isInfected {
                if self.dashButton.contains(touch.location(in: self.camera!)) {
                    player.dash()
                } else {
                    fireBullet(at: touch.location(in: self))
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let time = startTime, currentTime > time + TIME_TILL_ZOMBIES_MOVE {
            for p in players where p != self.player {
                if abs(p.physicsBody!.velocity.dx) < PlayerNode.SPEED / 2 && abs(p.physicsBody!.velocity.dy) < PlayerNode.SPEED / 2 {
                    let i = Int(arc4random()) % 4
                    
                    switch i {
                    case 0 :
                        p.setVelocity(CGVector(dx: PlayerNode.SPEED, dy: 0))
                    case 1 :
                        p.setVelocity(CGVector(dx: -PlayerNode.SPEED, dy: 0))
                    case 2 :
                        p.setVelocity(CGVector(dx: 0, dy: PlayerNode.SPEED))
                    case 3 :
                        p.setVelocity(CGVector(dx: 0, dy: -PlayerNode.SPEED))
                    default :
                        break
                    }
                }
            }
        } else if startTime == nil {
            startTime = currentTime
        }
        
        if cameraSet {
            camera!.run(SKAction.move(to: player.position, duration: 0.1))
        }
    }
}


extension SinglePlayerGameScene {
    fileprivate func fireBullet(at pos: CGPoint) {
        if Settings.getSettings().soundOn {
            run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        }
        
        let projectile = BulletNode(bulletInfo: nil)
        let offset = pos - player.position
        let direction = offset.normalized()
        projectile.position = CGPoint(x: player.position.x + 0.01*direction.x, y: player.position.y + 0.01*direction.y)
        
        let shootVector = CGVector(dx: direction.x * BulletNode.SPEED, dy: direction.y * BulletNode.SPEED)
        projectile.physicsBody?.velocity = shootVector
        addChild(projectile)
    }
}


extension SinglePlayerGameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case BitMask.bullet.rawValue | BitMask.wall.rawValue:
            let bullet = contact.bodyB.node
            bullet?.removeFromParent()
            
        case BitMask.bullet.rawValue | BitMask.player.rawValue:
            let hitPlayer = contact.bodyA.node as! PlayerNode
            if hitPlayer.isInfected {
                contact.bodyB.node?.removeFromParent()
                hitPlayer.removeFromParent()
                level.placePlayer(player: hitPlayer)
                self.addChild(hitPlayer)
                self.playerHeader.score += 1
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
        case BitMask.wall.rawValue | BitMask.player.rawValue:
            let collidingPlayer = contact.bodyB.node as! PlayerNode
            collidingPlayer.removeAllActions()
            collidingPlayer.isDashing = false
            
        default:
            break
        }
    }
}
