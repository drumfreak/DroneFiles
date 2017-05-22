//
//  EditorTabViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/21/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz

class EditorTabViewController: NSTabViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.editorTabViewController = self
        
        view.wantsLayer = true
        // change the background color of the layer
        view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.tabView.tabViewItem(at: 0).color =  self.appSettings.appViewBackgroundColor
        
    }
    
}
