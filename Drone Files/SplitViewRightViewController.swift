//
//  SplitViewRightViewController.swift
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


class SplitViewRightViewController: NSViewController {
    
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var screenshotViewController: ScreenshotViewController!
    // @IBOutlet weak var editorViewController: EditorViewController!
    @IBOutlet weak var editorTabViewController: EditorTabViewController!
    @IBOutlet weak var imageEditorViewController: ImageEditorViewController!
    @IBOutlet weak var splitViewController: SplitViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("Subview Loded")
        // print("SplitViewRightViewController")
        
        //  self.performSegue(withIdentifier: "videoPlayerSegue", sender: self)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "editorTabViewSegue" {
            self.editorTabViewController = segue.destinationController as! EditorTabViewController
            
            self.videoPlayerViewController = self.editorTabViewController.childViewControllers[0] as! VideoPlayerViewController
            
            self.videoPlayerViewController.editorTabViewController = self.editorTabViewController
    
            self.screenshotViewController = self.editorTabViewController.childViewControllers[1] as! ScreenshotViewController
            
            self.screenshotViewController.editorTabViewController = self.editorTabViewController
            
            self.imageEditorViewController = self.editorTabViewController.childViewControllers[2] as! ImageEditorViewController
            
            self.imageEditorViewController.editorTabViewController = self.editorTabViewController
            
        }
    }
}
