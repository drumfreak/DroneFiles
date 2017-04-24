//
//  EditorViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/20/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation

import Cocoa
import AVKit
import AppKit
import AVFoundation


class EditorViewController: NSViewController {
    
    
    
    @IBOutlet var mainContainerView: NSView!
    
    @IBOutlet weak var screenShotViewController: ScreenshotViewController!
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // print("Subview Loded")
        print("Editor Container Loaded")
        
        self.performSegue(withIdentifier: "videoPlayerSegue", sender: self)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        print("SEGUE");
        print(segue.identifier!)
        if segue.identifier == "videoPlayerSegue" {
            self.videoPlayerViewController = segue.destinationController as! VideoPlayerViewController
            print ("Videos Loaded by segue");
        }
        
        if segue.identifier == "screenShotSave" {
            
            print ("Screen Shots Loaded by segue");
        }
    }

}




