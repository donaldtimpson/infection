//
//  CGVector+Extension.swift
//  Infection
//
//  Created by Donald Timpson on 3/11/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit

func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

func - (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}

func * (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

func / (vector: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
}

extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    func normalized() -> CGVector {
        return self / self.length()
    }
}
