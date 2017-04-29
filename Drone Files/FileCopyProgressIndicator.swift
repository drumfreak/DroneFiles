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


class FileCopyProgressIndicatorController: NSViewController {
    @IBOutlet var fileCopyProgressIndicator: NSProgressIndicator!
    @IBOutlet var fileCopyStatusLabel: NSTextField!
    @IBOutlet weak var whatTheFucktimer: Timer!
    var copyFromUrls = NSMutableArray()
    var copyToUrls = NSMutableArray()
    var progress = 0.0  {
        didSet {
            print("Set my progress to: \(self.progress)")
        }
    }
    
    var destinationSize = Int(0) {
        didSet {
            print("Set my destinationSize to: \(self.destinationSize)")
            DispatchQueue.main.async {
                self.updateProgressLabel()
            }
            
        }
    }

    var totalNumfiles = Int(0) {
        didSet {
            print("Set my totalNumfiles to: \(self.totalNumfiles)")
            DispatchQueue.main.async {
                self.updateProgressLabel()
            }
        }
    }

    var totalNumfilesTransferred = Int(0) {
        didSet {
            print("Set my totalNumfilesTransferred to: \(self.totalNumfilesTransferred)")
            
            self.progress = ceil(Double(Double(self.totalNumfilesTransferred) / Double(self.totalNumfiles))*100)
            DispatchQueue.main.async {
                self.updateProgressLabel()
            }
        }
    }

    
    var currentFileNumber = Int(0) {
        didSet {
            print("Set my currentFileNumber to: \(self.currentFileNumber)")
            DispatchQueue.main.async {
                self.updateProgressLabel()
            }
        }
    }
    
    var desitnationCurrentSize = Int(0) {
        didSet {
            print("Set my desitnationCurrentSize to: \(self.desitnationCurrentSize)")
            DispatchQueue.main.async {
                self.updateProgressLabel()
            }
        }
    }

    var destinationCurrentFileSize  = Int(0) {
        didSet {
            print("Set my destinationCurrentFileSize to: \(self.destinationCurrentFileSize)")
            DispatchQueue.main.async {
                self.updateProgressLabel()
            }
        }
    }
    
    var destinationCurrentFile = String() {
        didSet {
            print("Set my destination File to:" + self.destinationCurrentFile)
            DispatchQueue.main.async {
                self.updateProgressLabel()
            }
        }
    }
    
    @IBOutlet var okayButton: NSButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        print("Hey fucker... copy progress indicator is loaded")
        self.okayButton.isHidden = true
        self.startTimer()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.stopTimer()
    }

    func updateProgressLabel() {
    
        let filesTransferred =  String(format: "%2d", self.totalNumfilesTransferred)
        
        let numFilestotal =  String(format: "%2d", self.totalNumfiles)
        
        let destinationSize =  self.appDelegate.fileManagerViewController.bytesToHuman(size: Int64(self.destinationSize))
        
        self.fileCopyStatusLabel.stringValue = filesTransferred + " of " + numFilestotal + " / " + " 0 of " + destinationSize
        
        
    }
    func updateProgressBarCopy() {
        DispatchQueue.main.async {
            print("Incrementing")
        }
        
        if(self.progress < 100.0) {
            self.fileCopyProgressIndicator.doubleValue = Double(self.progress)
        } else {
            self.stopTimer()
            self.fileCopyProgressIndicator.doubleValue = 100.0
            self.fileCopyProgressIndicator.stopAnimation(nil)
            // self.fileCopyProgressIndicator.isHidden = true
            self.okayButton.isHidden = false
        }
        
        DispatchQueue.main.async {
            self.updateProgressLabel()
        }
    }
    
    @IBAction func closeWindow(_ sender: AnyObject) {
        self.appDelegate.fileManagerOptionsCopyController.dismissViewController(self)
    }
    
    func startTimer() {
        // if(self.whatTheFucktimer == nil) {
            DispatchQueue.main.async {
                // print(self.whatTheFucktimer)
                print("Running Timer")
                self.whatTheFucktimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector:#selector(self.updateProgressBarCopy), userInfo: nil, repeats: true)
            
                RunLoop.current.add(self.whatTheFucktimer, forMode: RunLoopMode.commonModes)
                // print(self.whatTheFucktimer)
            }
       // }
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
