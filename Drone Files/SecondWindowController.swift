//
//  SecondWindowController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/19/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//
import Cocoa

class SecondWindowController: NSWindowController {
    // @IBOutlet weak var keyWindow: KeyCaptureWindow!
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        DispatchQueue.main.async {
            
            self.window?.titlebarAppearsTransparent = true
            self.window?.isMovableByWindowBackground = true
            self.window?.titleVisibility = NSWindowTitleVisibility.hidden
            self.window?.backgroundColor = self.appDelegate.appSettings.appViewBackgroundColor
        }
        // self.window?.screen = self.appDelegate.externalScreens[0]
        
        // super.window?.backgroundColor = NSColor(calibratedRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    
    
}
