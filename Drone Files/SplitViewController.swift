//
//  SplitViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/23/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {

    @IBOutlet var mySplitView: NSSplitView!
    @IBOutlet var leftView: NSSplitViewItem!
    @IBOutlet var rightView: NSSplitViewItem!
    @IBOutlet weak var screenshotViewController: ScreenshotViewController!
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var editorTabViewController: EditorTabViewController!
    @IBOutlet weak var filebrowserViewController: FileBrowserViewController!
    @IBOutlet weak var splitViewRightController: SplitViewRightViewController!
    @IBOutlet weak var imageEditorViewController: ImageEditorViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        // print("Split View Loaded")
        
        mySplitView.adjustSubviews();
        
        self.filebrowserViewController = self.childViewControllers[0] as! FileBrowserViewController
        
        self.splitViewRightController = self.childViewControllers[1] as! SplitViewRightViewController

        
        self.editorTabViewController  = self.splitViewRightController.editorTabViewController
        
        self.filebrowserViewController.editorTabViewController = self.editorTabViewController
        
        
        self.videoPlayerViewController = self.splitViewRightController.videoPlayerViewController!
        
        self.videoPlayerViewController.fileBrowserViewController = self.filebrowserViewController
        
        self.editorTabViewController  = self.splitViewRightController.editorTabViewController
        
        self.screenshotViewController  = self.splitViewRightController.screenshotViewController
        
          self.screenshotViewController.fileBrowserViewController = self.filebrowserViewController
        
        /*
        
        */
        
    }
    
}
