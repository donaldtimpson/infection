//
//  Stats+CoreDataProperties.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//
//

import Foundation
import CoreData


extension Stats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stats> {
        return NSFetchRequest<Stats>(entityName: "Stats")
    }

    @NSManaged public var bulletsHit: Int32
    @NSManaged public var bulletsShot: Int32
    @NSManaged public var gamesPlayed: Int32
    @NSManaged public var gamesWon: Int32
    @NSManaged public var killed: Int32
    @NSManaged public var playerskills: Int32
    @NSManaged public var zombiesKilled: Int32

}
