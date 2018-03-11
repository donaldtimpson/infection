//
//  Level.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit
import SpriteKit

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

class Cell {
    var xPos = 0
    var yPos = 0
    var hasLeftWall = true
    var hasRightWall = true
    var hasTopWall = true
    var hasBottomWall = true
    var visited = false
    
    convenience init(xPos: Int, yPos: Int, leftWall: Bool, rightWall: Bool, topWall: Bool, bottomWall: Bool) {
        
        self.init()
        self.xPos = xPos
        self.yPos = yPos
        self.hasLeftWall = leftWall
        self.hasRightWall = rightWall
        self.hasTopWall = topWall
        self.hasBottomWall = bottomWall
    }
}

class Level {
    var walls = [WallNode]()
    var floor = [FloorNode]()
    var wallsMatrix = [Int]()
    var cells = [Cell]()
    var height = 0
    var width = 0
    
    convenience init(encodedString: String) {
        self.init()
        
        var stringComponents = encodedString.components(separatedBy: "-")
        width = Int(stringComponents[0])!
        stringComponents.remove(at: 0)
        height = Int(stringComponents[0])!
        stringComponents.remove(at: 0)
        
        wallsMatrix = stringComponents.map { Int($0)! }
    }
    
    convenience init(width: Int, height: Int) {
        self.init()
        
        self.width = width
        self.height = height
        self.walls = [WallNode]()
        
        for j in 0..<height {
            for i in 0..<width {
                let cell = Cell(xPos: i, yPos: j, leftWall: true, rightWall: true, topWall: true, bottomWall: true)
                cells.append(cell)
            }
        }
        
        carveWalls(xPos: 0, yPos: 0)
        generateMatrix()
    }
    
    func generateMatrix() {
        let widthForWallInGrid = width * 2 + 1
        let heightForWallsInGrid = height * 2 + 1
        wallsMatrix = [Int](repeating: 0, count: widthForWallInGrid * heightForWallsInGrid)
        
        for y in 0..<heightForWallsInGrid {
            for x in 0..<widthForWallInGrid {
                if (x % 2 == 0 && y % 2 == 0) {
                    let index = y * widthForWallInGrid + x
                    wallsMatrix[index] = 1
                }
            }
        }
        
        for cell in cells {
            let x = cell.xPos * 2 + 1
            let y = cell.yPos * 2 + 1
            
            if cell.hasLeftWall {
                let index = y * widthForWallInGrid + (x - 1)
                wallsMatrix[index] = 1
            }
            
            if cell.hasRightWall {
                let index = y * widthForWallInGrid + (x + 1)
                wallsMatrix[index] = 1
            }
            
            if cell.hasTopWall {
                let index = (y + 1) * widthForWallInGrid + x
                wallsMatrix[index] = 1
            }
            
            if cell.hasBottomWall {
                let index = (y - 1) * widthForWallInGrid + x
                wallsMatrix[index] = 1
            }
        }
        
        for _ in 0..<50 {
            let index = Int(arc4random()) % wallsMatrix.count
            
            if index % widthForWallInGrid != 0 && index / widthForWallInGrid != 0 && index % widthForWallInGrid != widthForWallInGrid - 1 && index / widthForWallInGrid != heightForWallsInGrid - 1 {
                wallsMatrix[index] = 0
            }
        }
    }
    
    func levelString() -> String {
        let stringWallsMatrix = wallsMatrix.flatMap { String($0) } as [String]
        let wallsMatrixString = stringWallsMatrix.joined(separator: "-")
        let levelString = "\(width)-\(height)-\(wallsMatrixString)"
        
        return levelString
    }
    
    func renderMap() {
        let widthForWallInGrid = width * 2 + 1
        
        for (index, value) in wallsMatrix.enumerated() {
            let x = index % widthForWallInGrid
            let y = index / widthForWallInGrid
            let xPos = CGFloat(x) * WallNode.WIDTH + 0.5 * WallNode.WIDTH
            let yPos = CGFloat(y) * WallNode.HEIGHT + 0.5 * WallNode.HEIGHT
            
            if value == 1 {
                let wallNode: WallNode
                
                if y == 0 || wallsMatrix[(y - 1) * widthForWallInGrid + x] == 0 { // No wall below
                    if x == 0 || wallsMatrix[y * widthForWallInGrid + x - 1] == 0 { // No wall to left
                        if x == (widthForWallInGrid - 1) || wallsMatrix[y * widthForWallInGrid + x + 1] == 0 { // No wall to right
                            wallNode = WallNode(orientation: .bottomEnd)
                        } else {
                            wallNode = WallNode(orientation: .leftEnd)
                        }
                    } else if x == (widthForWallInGrid - 1) || wallsMatrix[y * widthForWallInGrid + x + 1] == 0 { // No wall to right
                        wallNode = WallNode(orientation: .rightEnd)
                    } else {
                        wallNode = WallNode(orientation: .horizantal)
                    }
                    
                } else {
                    wallNode = WallNode(orientation: .vertical)
                }
                
                wallNode.position = CGPoint(x: xPos, y: yPos)
                walls.append(wallNode)
            } else {
                let floorNode = FloorNode(width: FloorNode.WIDTH, height: FloorNode.HEIGHT)
                floorNode.position = CGPoint(x: xPos, y: yPos)
                floor.append(floorNode)
            }
        }
    }
    
    func placePlayer(player: PlayerNode) {
        
        while true {
            let index = Int(arc4random()) % wallsMatrix.count
            let widthForWallInGrid = width * 2 + 1
            
            if wallsMatrix[index] == 0 {
                let x = index % widthForWallInGrid
                let y = index / widthForWallInGrid
                
                let xPos = CGFloat(x) * WallNode.WIDTH + 0.5 * WallNode.WIDTH
                let yPos = CGFloat(y) * WallNode.HEIGHT + 0.5 * WallNode.HEIGHT
                player.setPlayerPosition(position: CGPoint(x: xPos, y: yPos))
                
                break
            }
        }
    }
    
    func carveWalls(xPos: Int, yPos: Int) {
        var cellsToVisit = [Cell]()
        let index = xPos + yPos * width
        let currentCell = cells[index]
        currentCell.visited = true
        
        if xPos > 0 {
            let leftCell = cells[index - 1]
            if !leftCell.visited {
                cellsToVisit.append(leftCell)
            }
        }
        
        if xPos < (width - 1) {
            let rightCell = cells[index + 1]
            if !rightCell.visited {
                cellsToVisit.append(rightCell)
            }
        }
        
        if yPos > 0 {
            let bottomCell = cells[index - width]
            if !bottomCell.visited {
                cellsToVisit.append(bottomCell)
            }
        }
        
        if yPos < (height - 1) {
            let topCell = cells[index + width]
            if !topCell.visited {
                cellsToVisit.append(topCell)
            }
        }
        
        cellsToVisit = cellsToVisit.shuffled()
        
        for nextCell in cellsToVisit {
            
            // Left Cell
            if nextCell.yPos == yPos && nextCell.xPos < xPos {
                if nextCell.visited == false {
                    currentCell.hasLeftWall = false
                    nextCell.hasRightWall = false
                    carveWalls(xPos: xPos - 1, yPos: yPos)
                }
            }
            
            // Right Cell
            if nextCell.yPos == yPos && nextCell.xPos > xPos {
                if nextCell.visited == false {
                    currentCell.hasRightWall = false
                    nextCell.hasLeftWall = false
                    carveWalls(xPos: xPos + 1, yPos: yPos)
                }
            }
            
            // Bottom Cell
            if nextCell.xPos == xPos && nextCell.yPos < yPos {
                if nextCell.visited == false {
                    currentCell.hasBottomWall = false
                    nextCell.hasTopWall = false
                    carveWalls(xPos: xPos, yPos: yPos - 1)
                }
            }
            
            // Top Cell
            if nextCell.xPos == xPos && nextCell.yPos > yPos {
                if nextCell.visited == false {
                    currentCell.hasTopWall = false
                    nextCell.hasBottomWall = false
                    carveWalls(xPos: xPos, yPos: yPos + 1)
                }
            }
        }
    }
}
