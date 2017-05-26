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
}
