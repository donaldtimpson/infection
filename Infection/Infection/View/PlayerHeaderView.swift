//
//  PlayerHeaderView.swift
//  Infection
//
//  Created by Donald Timpson on 3/11/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import SpriteKit

class PlayerHeaderView: SKNode {
    
    var scoreLabel = SKLabelNode()
    var backButton = SKLabelNode()
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(self.score)"
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(width: CGFloat, height: CGFloat) {
        self.init()
        setupScoreLabel(width: width)
        setupBackButton(width: width)
        self.position = CGPoint(x: 0, y: height / 2 - 30)
    }
    
    func setupScoreLabel(width: CGFloat) {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: width / 2 - 50, y: 0)
        scoreLabel.zPosition = 10
        scoreLabel.fontName = "HelveticaNeue"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .red
        
        self.addChild(scoreLabel)
    }
    
    func setupBackButton(width: CGFloat) {
        backButton = SKLabelNode(text: "Back")
        backButton.position = CGPoint(x: -width / 2 + 50, y: 0)
        backButton.zPosition = 10
        backButton.fontName = "HelveticaNeue"
        backButton.fontSize = 20
        backButton.fontColor = .red
        
        self.addChild(backButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

