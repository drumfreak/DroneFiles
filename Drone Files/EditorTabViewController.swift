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
        
        self.appDelegate.videoPlayerViewController = self.childViewControllers[0] as! VideoPlayerViewController
        
        self.appDelegate.screenshotViewController = self.childViewControllers[1] as! ScreenshotViewController
    
        self.appDelegate.imageEditorViewController = self.childViewControllers[2] as! ImageEditorViewController
        
        self.appDelegate.editorTabViewController = self
    
    }
    
}
