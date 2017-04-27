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
    @IBOutlet weak var splitViewController: SplitViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("Subview Loded")
        // print("SplitViewRightViewController")
        
        //  self.performSegue(withIdentifier: "videoPlayerSegue", sender: self)
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "editorTabViewSegue" {
            
           //  self.appDelegate.editorTabViewController =  segue.destinationController as! EditorTabViewController

//            self.appDelegate.videoPlayerViewController = self.appDelegate.editorTabViewController?.childViewControllers[0] as! VideoPlayerViewController
//            
//            // self.videoPlayerViewController.editorTabViewController = self.editorTabViewController
//    
//            self.appDelegate.screenshotViewController = self.appDelegate.editorTabViewController?.childViewControllers[1] as! ScreenshotViewController
//            
//            // self.screenshotViewController.editorTabViewController = self.editorTabViewController
//            
//            self.appDelegate.imageEditorViewController = self.appDelegate.editorTabViewController?.childViewControllers[2] as! ImageEditorViewController
//            
//            // self.imageEditorViewController.editorTabViewController = self.editorTabViewController
//     
            
        }
    }
}
