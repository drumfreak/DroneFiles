//
//  FileManagerOptionsDeleteController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/25/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation


class FileManagerOptionsDeleteController: NSViewController {
    
    @IBOutlet weak var fileBrowserViewController: FileBrowserViewController!
    
    @IBOutlet weak var fileManagerViewController: FileManagerViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("FileManagerOptionsDeleteController loaded")
        
    }
}
