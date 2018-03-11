//
//  GameViewController.swift
//  Infection
//
//  Created by Donald Timpson on 1/22/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var level: Level!
    var singlePlayer: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(level != nil)
        
        if singlePlayer {
            let gameScene = SinglePlayerGameScene(level: level, size: self.view.frame.size)
            gameScene.parentController = self
            
            (self.view as! SKView).presentScene(gameScene)
        }
    }
}
