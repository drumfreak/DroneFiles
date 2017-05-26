//
//  FileCopyProgressIndicator.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/29/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//


import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz


class FileCopyProgressWindowController: NSWindowController {
    override var windowNibName: String? {
        return "FileCopyProgressWindow" // no extension .xib here
    }
    
    //    override func windowDidLoad() {
    //        super.windowDidLoad()
    //    }
    //
    //    override init(window: NSWindow!) {
    //        super.init(window: window)
    //     }
    //
    //    required init?(coder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    //
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //    }
    
}




class FileCopyProgressIndicatorController: NSViewController {
    
    @IBOutlet var window: NSWindow!

    
    @IBOutlet var fileCopyProgressIndicator: NSProgressIndicator!
    @IBOutlet var fileCopyStatusLabel: NSTextField!
    @IBOutlet weak var whatTheFucktimer: Timer!
    var copyFromUrls = NSMutableArray()
    var copyToUrls = NSMutableArray()
    var pauseTimer = false
    var progress = 0.0  {
        didSet {
            print("Set my progress to: \(self.progress)")
        }
    }
    
    var destinationSize = Int64(0) {
        didSet {
            print("Set my destinationSize to: \(self.destinationSize)")
            
        }
    }
    
    var totalNumfiles = Int(0) {
        didSet {
            print("Set my totalNumfiles to: \(self.totalNumfiles)")
            
        }
    }
    
    var totalNumfilesTransferred = Int(0) {
        didSet {
            print("Set my totalNumfilesTransferred to: \(self.totalNumfilesTransferred)")
            
        }
    }
    
    
    var currentFileNumber = Int(0) {
        didSet {
            print("Set my currentFileNumber to: \(self.currentFileNumber)")
            
        }
    }
    
    var destinationCurrentSize = Int64(0) {
        didSet {
            print("Set my desitnationCurrentSize to: \(self.destinationCurrentSize)")
        }
    }
    
    var destinationCurrentFileSize  = Int64(0) {
        didSet {
            print("Set my destinationCurrentFileSize to: \(self.destinationCurrentFileSize)")
        }
    }
    
    var bytesTransferred = Int64(0) {
        didSet {
            print("Bytes Transferred to: \(self.bytesTransferred)")
        }
    }
    
    var destinationCurrentFile = String() {
        didSet {
            print("Set my destination File to:" + self.destinationCurrentFile)
        }
    }
    
    var tmpSize = Int(0)
    
    @IBOutlet var okayButton: NSButton!    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor
        
        self.window?.orderFront(self.view.window)
        self.window?.becomeFirstResponder()
        self.window?.titlebarAppearsTransparent = true
        
        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.appDelegate.fileCopyProgressView = self

    }
    
   // 08RDE1G00101X9
    
    override func viewDidAppear() {
        super.viewDidAppear()
        print("Hey fucker... copy progress indicator is loaded")
        // self.okayButton.isHidden = true
        self.startTimer()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.stopTimer()
    }
    
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.stopTimer()
    }
    
    func updateProgressLabel() {
        
        let filesTransferred =  String(format: "%2d", self.totalNumfilesTransferred)
        
        let numFilestotal =  String(format: "%2d", self.totalNumfiles)
        
        let destination = self.destinationCurrentFile
        
        let foo = self.appDelegate.fileManagerViewController?.calculateSingleFileSize(fileUrl: destination)
        
        let tmpSize = self.destinationCurrentFileSize
        
        print("Tmp size: \(tmpSize)")
        
        let newSize = foo?["totalSize"] as! Int64
        
        let thisRun = (newSize - tmpSize)
        
        self.destinationCurrentFileSize = newSize
        
        if(thisRun > 0) {
            self.bytesTransferred += thisRun
            print("Bytes transferred... \(thisRun)")
        }
        
        print(self.destinationCurrentSize)
        
        let destinationSizeForLabel =  self.appDelegate.fileManagerViewController.bytesToHuman(size: Int64(self.destinationSize))
        
        let destinationCurrentSizeForLabel =  self.appDelegate.fileManagerViewController.bytesToHuman(size: Int64(self.bytesTransferred))
        
        self.fileCopyStatusLabel.stringValue = filesTransferred + " of " + numFilestotal + " / " + destinationCurrentSizeForLabel + " of " + destinationSizeForLabel
    }
    
    func updateProgressBarCopy() {
        //DispatchQueue.main.async {
        print("Incrementing")
        // }
        
        if(!self.pauseTimer) {
            self.progress = ceil(Double(Double(self.bytesTransferred) / Double(self.destinationSize))*100)
            
            DispatchQueue.main.async {
                self.updateProgressLabel()
                if(self.progress < 100.0) {
                    self.fileCopyProgressIndicator.doubleValue = Double(self.progress)
                    // self.updateProgressLabel()
                } else {
                    self.stopTimer()
                    self.fileCopyProgressIndicator.doubleValue = 100.0
                    self.fileCopyProgressIndicator.stopAnimation(nil)
                    // self.fileCopyProgressIndicator.isHidden = true
                    // self.okayButton.isHidden = false
                }
            }
        }
    }
    
    @IBAction func closeWindow(_ sender: AnyObject) {
        self.view.window?.close()
    }
    
    func startTimer() {
        // if(self.whatTheFucktimer == nil) {
        DispatchQueue.main.async {
            print("Running Timer")
        }
        
        // print(self.whatTheFucktimer)
        self.whatTheFucktimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector:#selector(self.updateProgressBarCopy), userInfo: nil, repeats: true)
        RunLoop.current.add(self.whatTheFucktimer, forMode: RunLoopMode.commonModes)
        
        
        // DispatchQueue.global(qos: .userInitiated).async {
        DispatchQueue.main.async {
            self.fileCopyProgressIndicator.startAnimation(nil)
        }
        //}
    }
    
    func stopTimer() {
        if(self.whatTheFucktimer != nil) {
            if(self.whatTheFucktimer.isValid) {
                print("Invalidating Timer")
                // RunLoop.current.add(self.whatTheFucktimer, forMode: RunLoopMode.commonModes)
                self.whatTheFucktimer.invalidate()
            }
        }
        
    }
    
    
    
}
