//
//  SettingsViewController.swift
//  Infection
//
//  Created by Donald Timpson on 11/10/17.
//  Copyright © 2017 Kraig Wastlund. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var backgroundMusicButton: UIButton!
    @IBOutlet weak var vibrateButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        soundButton.addTarget(self, action: #selector(soundButtonPressed(_:)), for: .touchUpInside)
        backgroundMusicButton.addTarget(self, action: #selector(backgroundMusicButtonPressed(_:)), for: .touchUpInside)
        vibrateButton.addTarget(self, action: #selector(vibrateButtonPressed(_:)), for: .touchUpInside)
        
        if Settings.getSettings().soundOn {
            soundButton.setTitle("ON", for: .normal)
        } else {
            soundButton.setTitle("OFF", for: .normal)
        }
        
        if Settings.getSettings().musicOn {
            backgroundMusicButton.setTitle("ON", for: .normal)
        } else {
            backgroundMusicButton.setTitle("OFF", for: .normal)
        }
        
        if Settings.getSettings().vibrateOn {
            vibrateButton.setTitle("ON", for: .normal)
        } else {
            vibrateButton.setTitle("OFF", for: .normal)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func soundButtonPressed(_ sender: UIButton) {
        let isOn = !Settings.getSettings().soundOn
        Settings.setSound(!Settings.getSettings().soundOn)

        if isOn {
            sender.setTitle("ON", for: .normal)
        } else {
            sender.setTitle("OFF", for: .normal)
        }
    }

    @objc func backgroundMusicButtonPressed(_ sender: UIButton) {
        let isOn = !Settings.getSettings().musicOn
        Settings.setBackgroundMusic(isOn)

        if isOn {
            sender.setTitle("ON", for: .normal)
        } else {
            sender.setTitle("OFF", for: .normal)
        }
    }

    @objc func vibrateButtonPressed(_ sender: UIButton) {
        let isOn = !Settings.getSettings().vibrateOn
        Settings.setVibrate(isOn)

        if isOn {
            sender.setTitle("ON", for: .normal)
        } else {
            sender.setTitle("OFF", for: .normal)
        }
    }
}
