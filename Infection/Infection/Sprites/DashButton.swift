//
//  DashButton.swift
//  Infection
//
//  Created by Donald Timpson on 3/11/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import SpriteKit

class DashButton: SKNode {
    
    var button = SKShapeNode()
    
    override init() {
        let buttonRect = CGRect(x: 0, y: 0, width: 80, height: 80)
        let buttonPath = UIBezierPath(ovalIn: buttonRect)
        
        button = SKShapeNode(path: buttonPath.cgPath, centered: true)
        button.fillColor = .gray
        button.alpha = 0.8
        button.strokeColor = .white
        
        super.init()
        self.zPosition = 6
        
        addChild(button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
