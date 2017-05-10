//
//  Window.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/26/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

// typealias Callback = (NSEvent) -> ()

class KeyCaptureWindow: NSWindow {

   // var appDelegate = NSApplication.shared().delegate as! AppDelegate
    
    var isCommandKeyPressed = false
    var keyPressed = 0
    
    
    override func flagsChanged(with event: NSEvent) {
        
        
        if(event.keyCode == 55) {
            isCommandKeyPressed = true
            return
        } else {
            isCommandKeyPressed = false
        }
        
        super.flagsChanged(with: event)
        // Swift.print("HAYYYY")

        //  appDelegate.
        
    }

    
    
    override func keyDown(with event: NSEvent) {
        // Swift.print("HAYYYY")
        
        
       
        if(event.keyCode == 33) { // Trim IN
            // Swift.print("Setting TRIM IN: \(event)!")
            appDelegate.videoPlayerControlsController.setTrimInFromKeyboard()
            return
        }
        
        if(event.keyCode == 30) { // Trim Out
            // Swift.print("Setting TRIM OUT: \(event)!")
            appDelegate.videoPlayerControlsController.setTrimOutFromKeyboard()
            return
        }
        
        
        if(isCommandKeyPressed) {
            if(event.keyCode == 17) {
                /// Swift.print("Caught a key down: \(event)!")
                appDelegate.videoPlayerControlsController.takeScreenShotFromKeyboard()
                return
            }
        }
        Swift.print(event.keyCode)

        super.keyDown(with: event)
        
       //  appDelegate.
        
    }
    
}
