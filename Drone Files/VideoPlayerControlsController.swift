//
//  VideoPlayerControlsController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/28/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//


import Foundation

import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz

class VideoPlayerControllsController: NSViewController {
    
    @IBOutlet var screenShotPreviewButton: NSButton!
    @IBOutlet var screenShotBurstEnabledButton: NSButton!
    
    
    // Video Trimming
    @IBOutlet var saveNewItemPreserveDate: NSButton!
    @IBOutlet var saveClipLoadNewItemCheckbox: NSButton!
    @IBOutlet var saveTrimmedClipView: NSView!
    // @IBOutlet weak var exportSession: AVAssetExportSession!
    @IBOutlet weak var clipTrimTimer: Timer!
    @IBOutlet weak var saveTrimmedVideoButton: NSButton!
    @IBOutlet weak var cancelTrimmedVideoButton: NSButton!
    @IBOutlet weak var clipFileSizeLabel: NSTextField!
    var clipFileSizeVar = Int64(0)
    let sizeFormatter = ByteCountFormatter()
    var userTrimmed = false
    var isTrimming = false
    var clippedItemPreserveFileDates = true
    var clippedItemLoadNewItem = true
    
    // Screenshotting
    var screenShotPreview = true
    var screenShotBurstEnabled = false
    var trimOffset = 0.00
    
    // Video Player Stuff
    var playerItem: AVPlayerItem!
    var currentVideoURL: URL!
    
    @IBOutlet weak var playerTimer: Timer!
    
    
    @IBOutlet var originalPlayerItem: AVPlayerItem!
    
    var nowPlayingURLString: String!
    var exportSession: AVAssetExportSession!
    
    @IBOutlet weak var nowPlayingFile: NSTextField!
    @IBOutlet weak var trimmedClipNewLabel: NSTextField!
    @IBOutlet weak var trimmedClipNewPathLabel: NSTextField!
    @IBOutlet weak var videoLengthLabel: NSTextField!
    @IBOutlet var currentFrameLabel: NSTextField!
    
    
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    
    @IBOutlet weak var dateField: NSTextField!
    @IBOutlet weak var flightName: NSTextField!
    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet var saveDirectoryName: String!
    @IBOutlet var flightNameVar: String!
    @IBOutlet var dateNameVar: String!
    @IBOutlet var clippedVideoPath: String!
    @IBOutlet var clippedVideoPathFull: String!
    @IBOutlet var clippedVideoPathFullURL: String!
    @IBOutlet var clippedVideoName: String!
    @IBOutlet var clippedVideoNameFull: String!
    @IBOutlet var clippedVideoNameFullURL: String!
    @IBOutlet var folderURL: String!
    @IBOutlet weak var folderURLDisplay: NSTextField!
    
    @IBOutlet var playerTimerLabel: NSTextField!
    var playerItemContext = 0
    @IBOutlet var clipTrimProgressBar: NSProgressIndicator!
    
    @IBOutlet var saveFilePreserveDatesButton: NSButton!
    
    @IBOutlet var savingScreenShotSpinner: NSProgressIndicator!
    @IBOutlet var savingScreenShotMessageBox: NSView!
    
    // Player Increment Buttons
    @IBOutlet var playerFrameDecrementButton: NSButton!
    @IBOutlet var playerFrameIncrementButton: NSButton!
    
    
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("Video Player Controller Loaded")
        
        self.clipTrimProgressBar.isHidden = true
        self.saveTrimmedClipView.isHidden = true
        self.saveTrimmedVideoButton.isHidden = true
        // self.savingScreenShotMessageBox.isHidden = true
        self.savingScreenShotSpinner.isHidden = true
        
        let defaults = UserDefaults.standard
        
        if(defaults.value(forKey: "previewScreenshot") == nil) {
            defaults.setValue(1, forKey: "previewScreenshot")
            defaults.setValue(0, forKey: "screenShotBurstEnabled")
            defaults.setValue(1, forKey: "clippedItemPreserveFileDates")
            defaults.setValue(0, forKey: "loadNewClip")
            defaults.setValue(3, forKey: "burstFrames")
        }
        
        self.screenShotBurstEnabledButton.state = (defaults.value(forKey: "screenShotBurstEnabled") as! Int)
        self.screenShotPreviewButton.state = (defaults.value(forKey: "previewScreenshot") as! Int)
        self.saveNewItemPreserveDate.state = (defaults.value(forKey: "clippedItemPreserveFileDates") as! Int)
        
        if(self.screenShotBurstEnabledButton.state == 0) {
            self.screenShotBurstEnabled = false
        }
        
        if(self.screenShotPreviewButton.state == 0) {
            self.screenShotPreview = false
        }
        
        if(self.saveNewItemPreserveDate.state == 0) {
            self.clippedItemPreserveFileDates = false
        }
        
        let tapGesture = NSClickGestureRecognizer(target: self, action: #selector(handlePlayerLabelClick))
        self.playerTimerLabel.addGestureRecognizer(tapGesture)
        
        self.appDelegate.videoPlayerControlsController = self
        
    }
    
    
    func startTimer() {
        DispatchQueue.main.async {
            if(self.playerTimer == nil) {
                //print("Launching timer");
                self.playerTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector:#selector(self.updateTimerLabel), userInfo:nil, repeats: true)
            }
        }
    }
    
    
    func stopTimer() {
        DispatchQueue.main.async {
            if(self.playerTimer != nil) {
                self.playerTimer.invalidate()
            }
        }
    }
    
    func updateTimerLabel() {
        // print("This is happening...")
        
        let cur = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        
        let durationSeconds = CMTimeGetSeconds((cur)!)
        // print(durationSeconds)
        let (h,m,s,_) = self.secondsToHoursMinutesSeconds(seconds: Int((durationSeconds)))
        self.playerTimerLabel.stringValue = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
        // + ":" + String(format: "%02d", ms)
        
        self.currentFrameLabel.stringValue = String(format: "%010f", durationSeconds)
    }
    
    
    
    func handlePlayerLabelClick() {
        print("Play Pause")
        if(self.appDelegate.videoPlayerViewController.playerView.player?.isPlaying)! {
            self.appDelegate.videoPlayerViewController?.playerView.player?.pause()
        } else {
            self.appDelegate.videoPlayerViewController?.playerView.player?.play()
        }
    }
    
    // Play / Pause / Increment / Decrement
    
    @IBAction func frameDecrement(_ sender: AnyObject?) {
        //print("Frame Decrement")
        self.appDelegate.videoPlayerViewController?.playerView.player?.pause()
        let currentTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        let oneFrame = CMTimeMakeWithSeconds(1.0 / 29.97, currentTime!.timescale);
        // let nextFrame = CMTimeAdd(currentTime!, oneFrame);
        let previousFrame = CMTimeSubtract(currentTime!, oneFrame);
        self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: previousFrame, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
            // print("Seeked to previous frame")
            self.updateTimerLabel()
        })
        
    }
    
    @IBAction func frameIncrement(_ sender: AnyObject?) {
        // print("Frame Increment")
        let currentTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        let oneFrame = CMTimeMakeWithSeconds(1.0 / 29.97, currentTime!.timescale);
        let nextFrame = CMTimeAdd(currentTime!, oneFrame);
        // let previousFrame = CMTimeSubtract(currentTime!, oneFrame);
        self.appDelegate.videoPlayerViewController?.playerView?.player?.seek(to: nextFrame, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
            self.updateTimerLabel()
            // print("Seeked to previous frame")
        })
    }
    
    
    
    // Video Clipping
    func getClippedVideosIncrement(_folder: String) -> String {
        var incrementer = "00"
        if FileManager.default.fileExists(atPath: self.clippedVideoPath) {
            // print("url is a folder url")
            // lets get the folder files
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.appDelegate.fileBrowserViewController.videoClipsFolder)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%02d", files.count)
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func getClippedVideoPath(_videoPath : String) -> String {
        self.clippedVideoPathFull = self.appDelegate.fileBrowserViewController.videoClipsFolder.replacingOccurrences(of: "%20", with: " ")
        self.clippedVideoPath = self.clippedVideoPathFull.replacingOccurrences(of: "file://", with: "")
        
        let increment = getClippedVideosIncrement(_folder: self.appDelegate.fileBrowserViewController.videoClipsFolder)
        
        self.clippedVideoName = self.appDelegate.fileBrowserViewController.saveDirectoryName + " - Clip " + increment + ".MOV"
        self.clippedVideoNameFull = self.clippedVideoPathFull + "/" + self.clippedVideoName
        self.clippedVideoNameFullURL = self.clippedVideoNameFull.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: self.clippedVideoNameFull.replacingOccurrences(of: "file://", with: "")) {
            print("Fuck that file exists..")
            let incrementer = "00000"
            self.clippedVideoName = self.appDelegate.fileBrowserViewController.saveDirectoryName + " - Clip " + increment + " - " + incrementer + ".MOV"
            self.clippedVideoNameFull = self.clippedVideoPathFull + "/" + self.clippedVideoName
            self.clippedVideoNameFullURL = self.clippedVideoNameFull.replacingOccurrences(of: " ", with: "%20")
            
        } else {
            print("That file does not exist..")
        }
        
        self.trimmedClipNewLabel.isHidden = false
        self.trimmedClipNewLabel.stringValue = self.clippedVideoName
        self.trimmedClipNewPathLabel.isHidden = false
        self.trimmedClipNewPathLabel.stringValue = self.clippedVideoPath
        
        return self.clippedVideoPath
    }
    
    
    @IBAction func setTrimPointIn(_ sender: AnyObject) {
        print("Setting Trim Point IN")
        
        if(!self.isTrimming) {
            doTheTrim()
        }
        
        let currentVideoTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime = currentVideoTime!
        
        if(self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime == kCMTimeInvalid) {
            // print("TRIMMED SKIPPING")
            self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime = (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.duration)!
        }
        
        self.startTrimming();
        
        // self.playerView.player?.seek(to: currentVideoTime)
        if(self.appDelegate.videoPlayerViewController?.playerView.player?.isPlaying == false) {
            self.appDelegate.videoPlayerViewController?.playerView.player?.play()
        }
    }
    
    
    @IBAction func setTrimPointOut(_ sender: AnyObject) {
        if(!self.isTrimming) {
            doTheTrim()
        }
        
        let currentVideoTime = (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.currentTime())!
        self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: currentVideoTime)
        self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime = currentVideoTime
        
        if(self.appDelegate.videoPlayerViewController?.playerView.player?.isPlaying == false) {
            self.appDelegate.videoPlayerViewController?.playerView.player?.play()
        }
        
        self.startTrimming()
    }
    
    func startTrimming() {
        // user selected Trim button (AVPlayerViewTrimResult.okButton)...
        self.userTrimmed = true
        self.saveTrimmedVideoButton.isHidden = false
        self.clippedVideoPath = self.getClippedVideoPath(_videoPath: " ")
        self.cancelTrimmedVideoButton.isHidden = false
        self.cancelTrimmedVideoButton.isEnabled = true
        self.saveTrimmedVideoButton.isEnabled = true
        self.calculateClipLength()
        self.setupAvExportTrimmedClip()
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60, (seconds % 36000) % 60)
    }
    
    func calculateClipLength() {
        print("Calling Calculate Clip Length")
        if(self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime == kCMTimeInvalid) {
            self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime = (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.duration)!
        }
        
        if(self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime == kCMTimeInvalid) {
            self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime = kCMTimeZero
        }
        
        let difference = CMTimeSubtract((self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime)!, (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime)!)
        
        let durationSeconds = CMTimeGetSeconds(difference);
        
        if(durationSeconds > 0) {
            let (h,m,s,_) = self.secondsToHoursMinutesSeconds(seconds: Int(round(durationSeconds)))
            self.videoLengthLabel.stringValue = String(format: "%02d", h) + "h:" + String(format: "%02d", m) + "m:" + String(format: "%02d", s) + "s"
            // + String(format: "%02d", ms) + ":ms"
        } else {
            self.videoLengthLabel.stringValue = "00:00:0000"
        }
        
    }
    
    func doTheTrim() {
        if(self.appDelegate.videoPlayerViewController?.playerView.canBeginTrimming)! {
            if(!self.isTrimming) {
                self.isTrimming = true
                self.appDelegate.videoPlayerViewController?.playerView.beginTrimming { result in
                    if result == .okButton {
                        self.startTrimming()
                    } else {
                        self.cancelTrimmedClip(self)
                    }
                }
            }
        } else {
            print("CANNOT BEGIN TRIMMING. DAMMIT")
        }
        
    }
    
    
    @IBAction func setPreserveOriginalDates(_ sender: AnyObject) {
        self.clippedItemPreserveFileDates = !self.clippedItemPreserveFileDates
        //print("Preserve Original Dates Clicked")
        //print("Preserve Original Dates Clicked \(self.clippedItemPreserveFileDates)")
        if(self.clippedItemPreserveFileDates) {
            UserDefaults.standard.setValue(1, forKey: "clippedItemPreserveFileDates")
        } else {
            UserDefaults.standard.setValue(0, forKey: "clippedItemPreserveFileDates")
        }
    }
    
    @IBAction func setScreenShotBurstEnable(_ sender: AnyObject) {
        self.screenShotBurstEnabled = !self.screenShotBurstEnabled
        if(self.screenShotBurstEnabled) {
            UserDefaults.standard.setValue(1, forKey: "screenShotBurstEnabled")
        } else {
            UserDefaults.standard.setValue(0, forKey: "screenShotBurstEnabled")
        }
    }
    
    @IBAction func setLoadNewClipItem(_ sender: AnyObject) {
        self.clippedItemLoadNewItem = !self.clippedItemLoadNewItem
        //print("Load New Clip Clicked \(self.clippedItemLoadNewItem)")
        if(self.clippedItemLoadNewItem) {
            UserDefaults.standard.setValue(1, forKey: "clippedItemLoadNewItem")
        } else {
            UserDefaults.standard.setValue(0, forKey: "clippedItemLoadNewItem")
        }
    }
    
    
    @IBAction func setPreviewScreenshot(_ sender: AnyObject) {
        self.screenShotPreview = !self.screenShotPreview
        if(self.screenShotPreview) {
            UserDefaults.standard.setValue(1, forKey: "previewScreenshot")
        } else {
            UserDefaults.standard.setValue(0, forKey: "previewScreenshot")
        }
    }
    
    
    @IBAction func cancelTrimmedClip(_ sender: AnyObject?) {
        //print("Canceling Save Trimmed Clip");
        // let currentVideoTime = self.playerItem.currentTime()
        self.isTrimming = false;
        self.saveTrimmedClipView.isHidden = true
        self.cancelTrimmedVideoButton.isHidden = true
        self.userTrimmed = false
        self.saveTrimmedVideoButton.isHidden = true
        self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime = kCMTimeZero
        self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime = (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.duration)!
        
        if(self.exportSession.status == .exporting) {
            print("Cancelling Export!");
            self.exportSession.cancelExport();
        }
        
        // self.playVideo(_url:self.nowPlayingURL, frame: kCMTimeZero, startPlaying: true)
    }
    
    
    func updateProgressBar(session: Float) {
        let progress = self.exportSession.progress
        // print("calling update progress bar..\(self.exportSession.progress)")
        if(progress < 1.0) {
            self.clipTrimProgressBar.doubleValue = Double(progress)
        } else {
            self.clipTrimProgressBar.doubleValue = 1.0
            self.clipTrimProgressBar.stopAnimation(nil)
            self.clipTrimProgressBar.isHidden = true
        }
    }
    
    func setupAvExportTrimmedClip() {
        self.saveTrimmedClipView.isHidden = false
        self.clipTrimProgressBar.isHidden = true
        self.saveTrimmedVideoButton.isEnabled = true
        self.cancelTrimmedVideoButton.isEnabled = true
        
        self.exportSession = AVAssetExportSession(asset: (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.asset)!, presetName: AVAssetExportPresetHighestQuality)!
        
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie
        self.exportSession.outputURL = URL(string: self.clippedVideoNameFullURL)// Output URL
        
        let startTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime
        let endTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime
        let timeRange = CMTimeRangeFromTimeToTime(startTime!, endTime!)
        
        self.trimOffset = CMTimeGetSeconds(startTime!)
        
        self.exportSession.timeRange = timeRange
        
        // print("Export Length... \(self.exportSession.estimatedOutputFileLength)")
        
        self.clipFileSizeVar = self.exportSession.estimatedOutputFileLength
        self.clipFileSizeLabel.stringValue = String(format: "%2d", self.clipFileSizeVar);
    }
    
    @IBAction func saveTrimmedClip(_ sender: AnyObject?) {
        print ("Saving Trimmed Clip!!");
        
        self.clipTrimProgressBar.isHidden = false
        self.saveTrimmedVideoButton.isEnabled = false
        self.cancelTrimmedVideoButton.isEnabled = true
        
        do {
            try FileManager.default.createDirectory(atPath: self.clippedVideoPath, withIntermediateDirectories: true, attributes: nil)
        } catch _ as NSError {
            print("Error while creating a folder.")
        }
        
        
        self.clipTrimProgressBar.startAnimation(nil)
        self.clipTrimProgressBar.minValue = 0.0
        self.clipTrimProgressBar.maxValue = 1.0
        self.clipTrimProgressBar.isIndeterminate = false
        self.clipTrimProgressBar.doubleValue = 0.00
        
        func saveClippedFileCompleted() {
            print("Session Completed")
            self.saveTrimmedVideoButton.isHidden = true
            //self.saveTrimmedVideoButton.isEnabled = true
            self.trimmedClipNewLabel.isHidden = true
            self.trimmedClipNewLabel.stringValue = ""
            self.cancelTrimmedVideoButton.isHidden = true
            
            
            if(self.clippedItemPreserveFileDates) {
                self.setFileDate(originalFile: (self.nowPlayingURLString)!, newFile: self.clippedVideoNameFull.replacingOccurrences(of: "file://", with: ""))
            }
            self.clipTrimProgressBar.isHidden = true
            self.isTrimming = false
            
            // self.showNotification(messageType:"VideoTrimComplete", customMessage: self.clippedVideoPathFullURL)
            
            self.saveTrimmedClipView.isHidden = true
            
            // print("Claaned up session");
            self.appDelegate.fileBrowserViewController.reloadFileList()
            
        }
        
        func saveClippedFileFailed() {
            print("Session FAILED")
            self.saveTrimmedVideoButton.isEnabled = true
            // print ("Error: \(String(describing: exportSession.error))")
        }
        
        func saveClippedFileUnknown() {
            print("I don't know..");
        }
        
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            // print("Running queue damn! \(self.exportSession.progress)")
            self.exportSession.exportAsynchronously {
                //  print("AVSession progress \(self.exportSession.progress)")
                switch self.exportSession.status {
                case .completed:
                    DispatchQueue.main.async {
                        saveClippedFileCompleted()
                        self.clipTrimTimer.invalidate()
                    }
                    break
                case .failed:
                    DispatchQueue.main.async {
                        saveClippedFileFailed()
                        self.clipTrimTimer.invalidate()
                    }
                    
                    break
                default:
                    DispatchQueue.main.async {
                        saveClippedFileUnknown()
                        self.clipTrimTimer.invalidate()
                    }
                    break
                }
            }
            DispatchQueue.main.async {
                self.clipTrimTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(self.updateProgressBar), userInfo: (session: self.exportSession.progress), repeats: true)
            }
        }
    }
    
    func setFileDate(originalFile: String, newFile: String) {
        
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        original = original.replacingOccurrences(of: "%20", with: " ");
        
        var modifyFile = newFile.replacingOccurrences(of: "file://", with: "");
        modifyFile = newFile.replacingOccurrences(of: "%20", with: " ");
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: original)
            let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            
            let newDate = Calendar.current.date(byAdding: .second, value: Int(self.trimOffset), to: modificationDate)
            
            
            print("Modification date: ", newDate!)
            
            let attributes = [
                FileAttributeKey.creationDate: newDate!,
                FileAttributeKey.modificationDate: newDate!
            ]
            
            do {
                try FileManager.default.setAttributes(attributes, ofItemAtPath: modifyFile)
            } catch {
                print(error)
            }
        } catch let error {
            print("Error getting file modification attribute date: \(error.localizedDescription)")
        }
    }
    
    func getScreenShotDate(originalFile: String) -> Date {
        
        // print("TRIM OFFSET \(self.trimOffset)")
        
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        original = original.replacingOccurrences(of: "%20", with: " ");
        let date = Date()
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: original)
            let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            
            let newDate = Calendar.current.date(byAdding: .second, value: Int(self.trimOffset), to: modificationDate)
            
            // print("Modification date: ", newDate!)
            return newDate!
            
        } catch let error {
            print("Error getting file modification attribute date: \(error.localizedDescription)")
            return date
        }
        // return date
    }
    
    
    func takeScreenShotFromKeyboard() {
        //if(self.playerIsReady) {
        self.takeScreenshot("" as AnyObject)
        //}
    }
    
    func setTrimInFromKeyboard() {
        // if(self.playerIsReady) {
        self.setTrimPointIn("" as AnyObject)
        //  }
    }
    
    
    func setTrimOutFromKeyboard() {
        //if(self.playerIsReady) {
        self.setTrimPointOut("" as AnyObject)
        //}
    }
    
    
    @IBAction func takeScreenshot(_ sender: AnyObject?) {
        print("Taking Screenshot");
        //  self.savingScreenShotMessageBox.isHidden = true
        self.savingScreenShotSpinner.isHidden = false
        self.savingScreenShotSpinner.startAnimation(nil)
        
        let playerTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        
        var playerWasPlaying = false
        if(self.appDelegate.videoPlayerViewController?.playerView.player?.isPlaying)! {
            self.appDelegate.videoPlayerViewController?.playerView.player?.pause()
            playerWasPlaying = true
        }
        
        self.trimOffset = CMTimeGetSeconds((self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime())!)
        
        let newDate = getScreenShotDate(originalFile: self.nowPlayingURLString)
        
        
        if(self.screenShotPreview) {
            // THIS MUST HAPPEN FIRST
            self.savingScreenShotSpinner.stopAnimation(self)
            //self.savingScreenShotSpinner.isHidden = true
            self.appDelegate.editorTabViewController.selectedTabViewItemIndex = 1
            print("Screen shot at: \(String(describing: playerTime))")
            self.appDelegate.screenshotViewController?.takeScreenshot(asset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, currentTime: playerTime!, preview: true, modificationDate: newDate)
        } else {
            print("Screen shot at: \(String(describing: playerTime))")
            self.appDelegate.screenshotViewController?.takeScreenshot(asset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, currentTime: playerTime!, preview: false, modificationDate: newDate)
            if(playerWasPlaying) {
                self.savingScreenShotSpinner.stopAnimation(self)
                // self.savingScreenShotSpinner.isHidden = true
                self.appDelegate.videoPlayerViewController?.playerView.player?.play()
            }
        }
    }
    
    
    
    
    func showNotification(messageType: String, customMessage: String) -> Void {
        DispatchQueue.global(qos: .userInitiated).async {
            if(messageType == "VideoTrimComplete") {
                // print("Message Type VIDEO TRIM COMPLETE: " + messageType);
                let notification = NSUserNotification()
                notification.title = "Video Trimming Complete"
                notification.informativeText = "Your clip has been saved. " + customMessage.replacingOccurrences(of: "%20", with: " ")
                
                notification.soundName = NSUserNotificationDefaultSoundName
                // NSUserNotificationCenter.default.deliver(notification)
                NSUserNotificationCenter.default.deliver(notification);
            }
            
            if(messageType == "default") {
                // print("Message Type Welcome: " + messageType);
                let notification = NSUserNotification()
                notification.title = "Welcome to DroneFiles!"
                notification.informativeText = "Your life will never be the same"
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notification)
            }
        }
    }
    
    
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    
    
}
