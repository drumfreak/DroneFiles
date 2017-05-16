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
    @IBOutlet weak var splitViewRightController: SplitViewRightViewController!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        
        
        self.appDelegate.splitViewController = self
        // self.view.layer?.backgroundColor = CGColor.black
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func awakeFromNib() {
//        if self.view.layer != nil {
//            let color : CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1.0)
//            self.view.layer?.backgroundColor = color
//        }
        
    }
    
}
