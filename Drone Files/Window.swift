//
//  Window.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/26/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

typealias Callback = (NSEvent) -> ()

class KeyCaptureWindow: NSWindow {
    
    var keyEventListeners = Array<Callback>()
    
    override func keyDown(with event: NSEvent) {
        super.keyDown(with: event)

//        if event.modifierFlags.contains(NSEventModifierFlags.CommandKeyMask) {
//            super.keyDown(with: event)
//            return
//        }
//        for callback in keyEventListeners {
//            callback(event)
//        }
        
                for callback in keyEventListeners {
                    callback(event)
                }
        Swift.print("HAYYYY")
        Swift.print("Caught a key down: \(event)!")
      
    }
    
    func addKeyEventCallback(callback: @escaping Callback) {
        keyEventListeners.append(callback)
    }
    
    
}
