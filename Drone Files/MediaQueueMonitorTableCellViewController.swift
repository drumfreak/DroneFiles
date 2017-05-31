
//
//  MediaQueueMonitorTableCellViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/30/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class MediaQueueMonitorTableCellView: NSTableCellView {

    @IBOutlet var view: NSView!
    @IBOutlet var queueTitleLabel: NSTextField!
    @IBOutlet var queueFileNameLabel: NSTextField!

    @IBOutlet weak var queueTimer: Timer!
    @IBOutlet var queuePercentLabel: NSTextField!
    @IBOutlet var queueOverAllProgressIndicator: NSProgressIndicator!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    
}
