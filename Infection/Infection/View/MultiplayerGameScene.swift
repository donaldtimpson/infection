//
//  MultiplayerGameScene.swift
//  Infection
//
//  Created by Donald Timpson on 3/11/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import SpriteKit
import GameplayKit
import MultipeerConnectivity

class MultiplayerGameScene: SKScene, SKPhysicsContactDelegate {
    
    weak var parentController: UIViewController?
    var playerHeader: PlayerHeaderView!
    var joystick = Joystick()
    var dashButton = DashButton()
    var players: [PlayerNode] = []
    var player: PlayerNode!
    var cameraSet = false
    var level: Level!
    var addedIds = Set<MCPeerID>()
    var isMaster = false
    
    convenience init(level: Level, size: CGSize) {
        self.init(size: size)
        self.level = level
        
        MPCHandler.defaultHandler.delegate = self
        let playerInfo = PlayerInfo(peerID: MPCHandler.defaultHandler.peerID, position: CGPoint(), isInfected: false)
        self.player = PlayerNode(playerInfo: playerInfo)
        level.placePlayer(player: player)
        
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
        
        players.append(player)
        self.addChild(player)
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
                if self.isMaster {
                    self.player.isInfected = true
                    MPCHandler.defaultHandler.sendMessage(message: self.player.getInfo().getMessage())
                }
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
        if cameraSet {
            camera!.run(SKAction.move(to: player.position, duration: 0.1))
        }
        
        MPCHandler.defaultHandler.sendMessage(message: player.getInfo().getMessage())
    }
}


extension MultiplayerGameScene {
    fileprivate func fireBullet(at pos: CGPoint) {
        if Settings.getSettings().soundOn {
            run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        }
        
        let info = BulletInfo(peerID: player.peerId!, position: CGPoint(), velocity: CGVector())
        let projectile = BulletNode(bulletInfo: info)
        let offset = pos - player.position
        let direction = offset.normalized()
        projectile.position = CGPoint(x: player.position.x + 0.01*direction.x, y: player.position.y + 0.01*direction.y)
        
        let shootVector = CGVector(dx: direction.x * BulletNode.SPEED, dy: direction.y * BulletNode.SPEED)
        projectile.physicsBody?.velocity = shootVector
        
        MPCHandler.defaultHandler.sendMessage(message: projectile.getInfo().getMessage())
        addChild(projectile)
    }
}


extension MultiplayerGameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch contactMask {
        case BitMask.bullet.rawValue | BitMask.wall.rawValue:
            let bullet = contact.bodyB.node
            bullet?.removeFromParent()
            
        case BitMask.bullet.rawValue | BitMask.player.rawValue:
            let hitPlayer = contact.bodyA.node as! PlayerNode
            if hitPlayer.peerId != (contact.bodyB.node! as! BulletNode).peerID {
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


extension MultiplayerGameScene: MPCHandlerDelegate {
    func didRecieveLevel(level: Level) {
        print("This shouldn't happen....")
    }
    
    func didRecievePlayerInfo(playerInfo: PlayerInfo) {
        if !addedIds.contains(playerInfo.peerID) {
            addedIds.insert(playerInfo.peerID)
            let player = PlayerNode(playerInfo: playerInfo)
            players.append(player)
            self.addChild(player)
        } else {
            let player = players.filter({ $0.peerId! == playerInfo.peerID }).first!
            player.setPlayerPosition(position: playerInfo.position)
            player.isInfected = playerInfo.isInfected
        }
    }
    
    func didRecieveBulletInfo(bulletInfo: BulletInfo) {
        let bullet = BulletNode(bulletInfo: bulletInfo)
        self.addChild(bullet)
    }
}
