//
//  JoyStick.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import SpriteKit

class Joystick: SKNode {
    
    let MAX_RANGE: CGFloat = 35
    var joystick = SKShapeNode()
    var stick = SKShapeNode()
    var xValue: CGFloat = 0
    var yValue: CGFloat = 0
    
    var joystickAction: ((_ offset: CGPoint) -> ())?
    
    override init() {
        let joystickRect = CGRect(x: 0, y: 0, width: 120, height: 120)
        let joystickPath = UIBezierPath(ovalIn: joystickRect)
        
        joystick = SKShapeNode(path: joystickPath.cgPath, centered: true)
        joystick.fillColor = .gray
        joystick.alpha = 0.3
        joystick.strokeColor = .clear
        
        let stickRect = CGRect(x: 0, y: 0, width: 80, height: 80)
        let stickPath = UIBezierPath(ovalIn: stickRect)
        
        stick = SKShapeNode(path: stickPath.cgPath, centered: true)
        stick.fillColor = .gray
        stick.alpha = 0.8
        stick.strokeColor = .white
        
        super.init()
        self.zPosition = 6
        
        addChild(joystick)
        addChild(stick)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveJoyStick(touch: UITouch) {
        let p = touch.location(in: self)
        if p.length() < 100 {
            let x = p.x.clamped(-MAX_RANGE, MAX_RANGE)
            let y = p.y.clamped(-MAX_RANGE, MAX_RANGE)
            
            stick.position = CGPoint(x: x, y: y)
            xValue = x / MAX_RANGE
            yValue = y / MAX_RANGE
            
            if let action = joystickAction {
                let offset = CGPoint(x: xValue, y: yValue)
                action(offset)
            }
        }
    }
}

extension CGFloat {
    func clamped(_ v1: CGFloat, _ v2: CGFloat) -> CGFloat {
        let min = v1 < v2 ? v1 : v2
        let max = v1 > v2 ? v1 : v2
        
        return self < min ? min : (self > max ? max : self)
    }
}
