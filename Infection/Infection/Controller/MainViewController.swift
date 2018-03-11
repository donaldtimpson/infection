//
//  MainViewController.swift
//  Infection
//
//  Created by Donald Timpson on 3/10/18.
//  Copyright © 2018 Donald Timpson. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MainViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    var level: Level?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MPCHandler.defaultHandler.delegate = self
    }
    
    @IBAction func singlePlayerButtonPressed(_ sender: UIButton) {
        level = Level(width: 10, height: 10)
        level!.renderMap()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameVC.level = level
        gameVC.singlePlayer = true
        
        self.present(gameVC, animated: true, completion: nil)
    }
    
    @IBAction func multiplayerButtonPressed(_ sender: UIButton) {
        MPCHandler.defaultHandler.browser.delegate = self
        present(MPCHandler.defaultHandler.browser, animated: true, completion: nil)
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        MPCHandler.defaultHandler.browser.dismiss(animated: true, completion: nil)
        level = Level(width: 10, height: 10)
        level!.renderMap()
        
        let messageToSend: [String: Any] = ["level": level!.levelString()]
        MPCHandler.defaultHandler.sendMessage(message: messageToSend)
        startMultiplayerGame()
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        MPCHandler.defaultHandler.browser.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let settingsVC = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    func startMultiplayerGame() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let gameVC = storyboard.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController
        gameVC.level = level
        gameVC.singlePlayer = true
        
        self.present(gameVC, animated: true, completion: nil)
    }
}

extension MainViewController: MPCHandlerDelegate {
    func didRecieveLevel(level: Level) {
        self.level = level
        level.renderMap()
        startMultiplayerGame()
    }
}
