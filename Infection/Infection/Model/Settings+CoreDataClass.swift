//
//  Settings+CoreDataClass.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//
//

import Foundation
import CoreData

import Foundation
import CoreData
import AVFoundation

@objc(Settings)
public class Settings: NSManagedObject {
    
    static var context: NSManagedObjectContext!
    
    static let backgroundMusic: AVAudioPlayer = {
        do {
            return try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "background_music", ofType: "mp3")!) as URL)
        } catch {
            fatalError("Missing sound")
        }
    }()
    
    static let clickSound: AVAudioPlayer = {
        do {
            return try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: Bundle.main.path(forResource: "click", ofType: "wav")!) as URL)
        } catch {
            fatalError("Missing sound")
        }
    }()
    
    static func playBackgroundMusic() {
        let settings = Settings.getSettings()
        
        if settings.musicOn {
            let backGroundMusic = Settings.backgroundMusic
            backGroundMusic.numberOfLoops = -1
            backGroundMusic.play()
        }
    }
    
    static func playClickSound() {
        let settings = Settings.getSettings()
        
        if settings.soundOn {
            Settings.clickSound.play()
        }
    }
    
    static func vibrate() {
        let settings = Settings.getSettings()
        
        if settings.vibrateOn {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    static func setSound(_ on: Bool) {
        let settings = Settings.getSettings()
        
        settings.soundOn = on
        
        do {
            try settings.managedObjectContext?.save()
        } catch {
            assertionFailure()
        }
    }
    
    static func setBackgroundMusic(_ on: Bool) {
        let settings = Settings.getSettings()
        
        settings.musicOn = on
        
        if on {
            Settings.playBackgroundMusic()
        } else {
            Settings.backgroundMusic.stop()
        }
        
        do {
            try settings.managedObjectContext?.save()
        } catch {
            assertionFailure()
        }
    }
    
    static func setVibrate(_ on: Bool) {
        let settings = Settings.getSettings()
        
        settings.vibrateOn = on
        
        do {
            try settings.managedObjectContext?.save()
        } catch {
            assertionFailure()
        }
    }
    
    
    // Object
    static func getSettings() -> Settings {
        let settings: [Settings]
        let request: NSFetchRequest<Settings> = NSFetchRequest(entityName: "Settings")
        
        do {
            settings = try Settings.context.fetch(request)
        } catch {
            assertionFailure("failed to get user")
            return Settings()
        }
        
        if settings.count == 0 {
            return Settings()
        }
        
        return settings[0]
    }
    
    convenience init() {
        let entity = NSEntityDescription.entity(forEntityName: "Settings", in: Settings.context)
        
        self.init(entity: entity!, insertInto: Settings.context)
        self.soundOn = true
        self.musicOn = true
        self.vibrateOn = true
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            assertionFailure()
        }
    }
}
