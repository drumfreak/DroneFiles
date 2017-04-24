//
//  MainViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/23/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation

import Cocoa
import AVKit
import AppKit
import AVFoundation


class MainViewController: NSSplitViewController {
    
    @IBOutlet var mainContainerView: NSView!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Split View Loaded")
        // splitViewController?.preferredDisplayMode = .PrimaryOverlay
        
    }
}
