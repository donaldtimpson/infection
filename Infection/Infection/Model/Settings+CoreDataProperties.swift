//
//  Settings+CoreDataProperties.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings")
    }

    @NSManaged public var musicOn: Bool
    @NSManaged public var soundOn: Bool
    @NSManaged public var vibrateOn: Bool

}
