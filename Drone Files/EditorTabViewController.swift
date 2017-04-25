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

    @IBOutlet weak var screenshotViewController: ScreenshotViewController!
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var editorTabViewContrller: EditorTabViewController!
    @IBOutlet weak var mainViewController: FileBrowserViewController!
    @IBOutlet weak var imageEditorViewController: ImageEditorViewController!
    @IBOutlet weak var fileManagerViewController: FileManagerViewController!
    @IBOutlet weak var fileBrowserViewController: FileBrowserViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.videoPlayerViewController = self.childViewControllers[0] as! VideoPlayerViewController
        
        self.screenshotViewController = self.childViewControllers[1] as! ScreenshotViewController
    
        self.imageEditorViewController = self.childViewControllers[2] as! ImageEditorViewController
        
        self.fileManagerViewController = self.childViewControllers[3] as! FileManagerViewController

    }
    
}
