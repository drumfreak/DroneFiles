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
    
    // Screenshotting
    var screenShotBurstEnabled = false
    var trimOffset = 0.00
    
    @IBOutlet var screenShotPreviewButton: NSButton!
    @IBOutlet var screenShotBurstEnabledButton: NSButton!
    @IBOutlet var screenshotSoundButton: NSButton!
    
    // Video Trimming
    @IBOutlet var saveNewItemPreserveDate: NSButton!
    @IBOutlet var saveClipLoadNewItemCheckbox: NSButton!
    @IBOutlet var saveTrimmedClipView: NSView!
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
    
    
    // Metadata
    @IBOutlet var screenshotTypeJPGButton: NSButton!
    @IBOutlet var screenshotTypePNGButton: NSButton!
    
    
    var screenshotSound = true
    var screenshotJPG = true
    var screenshotPNG = true
    var screenshotPreserveClipName = true
    
    @IBOutlet var metadataLocationLabel: NSTextField!
    
    // Video Player Stuff
    var playerItem: AVPlayerItem!
    var currentVideoURL: URL!
    
    @IBOutlet weak var playerTimer: Timer!
    @IBOutlet var originalPlayerItem: AVPlayerItem!
    
    var nowPlayingURLString: String!
    var exportSession: AVAssetExportSession!
    
    var sharingDelegate: NSSharingServiceDelegate!
    
    @IBOutlet weak var nowPlayingFile: NSTextField!
    @IBOutlet weak var trimmedClipNewLabel: NSTextField!
    @IBOutlet weak var trimmedClipNewPathLabel: NSTextField!
    @IBOutlet weak var videoLengthLabel: NSTextField!
    @IBOutlet var currentFrameLabel: NSTextField!
    
    
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    
    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet var saveDirectoryName: String!
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
    @IBOutlet var screenshotPreserveClipNameButton: NSButton!
    
    @IBOutlet var videoRateSlider: NSSlider!
    @IBOutlet var playerRateResetButton: NSButton!
    @IBOutlet var playerRateLabel: NSTextField!
    
    
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
        
        self.screenshotPreserveClipNameButton.state = (defaults.value(forKey: "screenshotPreserveClipName") as! Int)
        
        self.screenshotSoundButton.state = (defaults.value(forKey: "screenshotSound") as! Int)
        
        self.screenShotBurstEnabledButton.state = (defaults.value(forKey: "screenShotBurstEnabled") as! Int)
        
        self.screenShotPreviewButton.state = (defaults.value(forKey: "previewScreenshot") as! Int)
        
        self.saveNewItemPreserveDate.state = (defaults.value(forKey: "clippedItemPreserveFileDates") as! Int)
        
        self.screenshotTypeJPGButton.state = (defaults.value(forKey: "screenshotJPG") as! Int)
        
        self.screenshotTypePNGButton.state = (defaults.value(forKey: "screenshotPNG") as! Int)
        
        if(self.screenShotBurstEnabledButton.state == 0) {
            self.screenShotBurstEnabled = false
        }
        
        if(self.screenShotPreviewButton.state == 0) {
            self.appDelegate.screenshotPreview = false
        }
        
        if(self.saveNewItemPreserveDate.state == 0) {
            self.clippedItemPreserveFileDates = false
        }
        
        
        if(self.screenshotTypeJPGButton.state == 0) {
            self.screenshotJPG = false
        }
        
        if(self.screenshotTypePNGButton.state == 0) {
            self.screenshotPNG = false
        }
        
        let tapGesture = NSClickGestureRecognizer(target: self, action: #selector(handlePlayerLabelClick))
        self.playerTimerLabel.addGestureRecognizer(tapGesture)
        
        self.appDelegate.videoPlayerControlsController = self
        
    }
    
    
    func startTimer() {
        DispatchQueue.main.async {
            if(self.playerTimer == nil) {
                //print("Launching timer");
                self.playerTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector:#selector(self.updateTimerLabel), userInfo:nil, repeats: true)
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
        let cur = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        
        let durationSeconds = CMTimeGetSeconds((cur)!)
        
        let (h,m,s,_) = self.secondsToHoursMinutesSeconds(seconds: Int((durationSeconds)))
        self.playerTimerLabel.stringValue = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
        
        self.currentFrameLabel.stringValue = String(format: "%02f", durationSeconds)
    }
    
    
    
    @IBAction func rateSliderChanged(_ sender: NSSlider) {
        // let slider = sender as! NSSlider
        print(sender.doubleValue)
        self.appDelegate.videoPlayerViewController?.videoRate = sender.doubleValue
        
        self.appDelegate.videoPlayerViewController?.playerView.player?.rate = Float((self.appDelegate.videoPlayerViewController?.videoRate)!)
        
        self.playerRateLabel.stringValue = String(format: "%02f", sender.doubleValue)
        
        
    }
    
    
    @IBAction func rateReset(_ sender: NSButton) {
        // let slider = sender as! NSSlider
        self.appDelegate.videoPlayerViewController?.videoRate = 1.0
        self.appDelegate.videoPlayerViewController?.playerView.player?.rate = Float((self.appDelegate.videoPlayerViewController?.videoRate)!)
        
        self.videoRateSlider.doubleValue = 1.0
        
        self.playerRateLabel.stringValue = String(format: "%02d", 1.0)
        
        
    }
    
    
    func handlePlayerLabelClick() {
        print("Play Pause")
        if(self.appDelegate.videoPlayerViewController?.playerView.player?.isPlaying)! {
            self.appDelegate.videoPlayerViewController?.playerView.player?.pause()
        } else {
            self.appDelegate.videoPlayerViewController?.playerView.player?.play()
            self.appDelegate.videoPlayerViewController?.playerView.player?.rate = Float((self.appDelegate.videoPlayerViewController?.videoRate)!)
            
        }
    }
    
    // Play / Pause / Increment / Decrement
    
    @IBAction func frameDecrement(_ sender: AnyObject?) {
        
        // if(  self.appDelegate.videoPlayerViewController?.playerItem)
        if(self.appDelegate.videoPlayerViewController?.playerView.player != nil) {
            self.appDelegate.videoPlayerViewController?.playerView.player?.pause()
            let currentTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
            let oneFrame = CMTimeMakeWithSeconds(1.0 / 29.97, currentTime!.timescale);
            
            let previousFrame = CMTimeSubtract(currentTime!, oneFrame);
            self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: previousFrame, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
                self.updateTimerLabel()
            })
            
        }
        
    }
    
    @IBAction func frameIncrement(_ sender: AnyObject?) {
        
        if(self.appDelegate.videoPlayerViewController?.playerView.player != nil) {
            
            
            let currentTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
            self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
            let oneFrame = CMTimeMakeWithSeconds(1.0 / 29.97, currentTime!.timescale);
            let nextFrame = CMTimeAdd(currentTime!, oneFrame);
            self.appDelegate.videoPlayerViewController?.playerView?.player?.seek(to: nextFrame, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
                self.updateTimerLabel()
            })
            
        }
        
        
        
    }
    
    
    
    // Video Clipping
    func getClippedVideosIncrement(_folder: String) -> String {
        var incrementer = "00"
        if FileManager.default.fileExists(atPath: self.clippedVideoPath) {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.appSettings.videoClipsFolder)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%02d", files.count)
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func getClippedVideoPath(_videoPath : String) -> String {
        self.clippedVideoPathFull = self.appSettings.videoClipsFolder.replacingOccurrences(of: "%20", with: " ")
        self.clippedVideoPath = self.clippedVideoPathFull.replacingOccurrences(of: "file://", with: "")
        
        let increment = getClippedVideosIncrement(_folder: self.appSettings.videoClipsFolder)
        
        self.clippedVideoName = self.appSettings.saveDirectoryName + " - Clip " + increment + ".MOV"
        self.clippedVideoNameFull = self.clippedVideoPathFull + "/" + self.clippedVideoName
        self.clippedVideoNameFullURL = self.clippedVideoNameFull.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: self.clippedVideoNameFull.replacingOccurrences(of: "file://", with: "")) {
            print("Fuck that file exists..")
            let incrementer = "00000"
            self.clippedVideoName = self.appSettings.saveDirectoryName + " - Clip " + increment + " - " + incrementer + ".MOV"
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
        // print("Calling Calculate Clip Length")
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
        
        if(self.clippedItemLoadNewItem) {
            UserDefaults.standard.setValue(1, forKey: "clippedItemLoadNewItem")
        } else {
            UserDefaults.standard.setValue(0, forKey: "clippedItemLoadNewItem")
        }
    }
    
    
    @IBAction func setPreviewScreenshot(_ sender: AnyObject) {
        self.appDelegate.screenshotPreview = !self.appDelegate.screenshotPreview
        if(self.appDelegate.screenshotPreview) {
            UserDefaults.standard.setValue(1, forKey: "previewScreenshot")
        } else {
            UserDefaults.standard.setValue(0, forKey: "previewScreenshot")
        }
    }
    
    
    @IBAction func setScreenshotTypePNG(_ sender: AnyObject) {
        self.screenshotPNG = !self.screenshotPNG
        if(self.screenshotPNG) {
            UserDefaults.standard.setValue(1, forKey: "screenshotPNG")
            UserDefaults.standard.setValue(0, forKey: "screenshotJPG")
            self.screenshotTypeJPGButton.state = 0
        } else {
            UserDefaults.standard.setValue(0, forKey: "screenshotPNG")
            UserDefaults.standard.setValue(1, forKey: "screenshotJPG")
            self.screenshotTypeJPGButton.state = 1
        }
    }
    
    
    @IBAction func setScreenshotTypeJPG(_ sender: AnyObject) {
        self.screenshotJPG = !self.screenshotJPG
        if(self.screenshotJPG) {
            UserDefaults.standard.setValue(1, forKey: "screenshotJPG")
            UserDefaults.standard.setValue(0, forKey: "screenshotPNG")
            self.screenshotTypePNGButton.state = 0
        } else {
            UserDefaults.standard.setValue(0, forKey: "screenshotJPG")
            UserDefaults.standard.setValue(1, forKey: "screenshotPNG")
            self.screenshotTypePNGButton.state = 1
        }
    }
    
    @IBAction func setScreenShotPreserveClipName(_ sender: AnyObject) {
        self.screenshotPreserveClipName = !self.screenshotPreserveClipName
        
        if(self.screenshotPreserveClipName) {
            UserDefaults.standard.setValue(0, forKey: "screnshotPreserveClipName")
        } else {
            UserDefaults.standard.setValue(1, forKey: "screnshotPreserveClipName")
        }
    }
    
    @IBAction func setScreenShotSound(_ sender: AnyObject) {
        self.screenshotSound = !self.screenshotSound
        if(self.screenshotSound) {
            UserDefaults.standard.setValue(1, forKey: "screenshotSound")
        } else {
            UserDefaults.standard.setValue(0, forKey: "screenshotSound")
        }
    }
    
    
    @IBAction func cancelTrimmedClip(_ sender: AnyObject?) {
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
    }
    
    
    func updateProgressBar(session: Float) {
        let progress = self.exportSession.progress
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
            self.trimmedClipNewLabel.isHidden = true
            self.trimmedClipNewLabel.stringValue = ""
            self.cancelTrimmedVideoButton.isHidden = true
            
            if(self.clippedItemPreserveFileDates) {
                self.setFileDate(originalFile: (self.nowPlayingURLString)!, newFile: self.clippedVideoNameFull.replacingOccurrences(of: "file://", with: ""))
            }
            self.clipTrimProgressBar.isHidden = true
            self.isTrimming = false
            
            self.saveTrimmedClipView.isHidden = true
            
            self.appDelegate.fileBrowserViewController.reloadFileList()
            
        }
        
        func saveClippedFileFailed() {
            print("Session FAILED")
            self.saveTrimmedVideoButton.isEnabled = true
        }
        
        func saveClippedFileUnknown() {
            print("I don't know..");
        }
        
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            self.exportSession.exportAsynchronously {
                
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
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        original = original.replacingOccurrences(of: "%20", with: " ");
        let date = Date()
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: original)
            let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            
            let newDate = Calendar.current.date(byAdding: .second, value: Int(self.trimOffset), to: modificationDate)
            
            return newDate!
            
        } catch let error {
            print("Error getting file modification attribute date: \(error.localizedDescription)")
            return date
        }
    }
    
    
    func takeScreenShotFromKeyboard() {
        //if(self.playerIsReady) {
        self.takeScreenshot("" as AnyObject)
        //}
    }
    
    func setTrimInFromKeyboard() {
        self.setTrimPointIn("" as AnyObject)
    }
    
    
    func setTrimOutFromKeyboard() {
        //if(self.playerIsReady) {
        self.setTrimPointOut("" as AnyObject)
        //}
    }
    
    func frameIncrementFromKeyboard() {
        //if(self.playerIsReady) {
        self.frameIncrement("" as AnyObject)
        //}
    }
    
    
    func frameDecrementFromKeyboard() {
        //if(self.playerIsReady) {
        self.frameDecrement("" as AnyObject)
        //}
    }
    
    
    
    @IBAction func takeScreenshot(_ sender: AnyObject?) {
        
        let playerTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        
        let numBursts = 5
        let interval = 0.2
        
        
        if(self.screenShotBurstEnabled) {
            DispatchQueue.global(qos: .userInitiated).async {

            /// let oneFrame = CMTimeMakeWithSeconds(0.1, playerTime!.timescale);
            
            
            var i = Int(numBursts)
            
            while(i > 0) {
                
                let oneFrame = CMTimeMakeWithSeconds((Double(i) * interval), playerTime!.timescale);

                let playerTime1 = CMTimeSubtract(playerTime!, oneFrame);

                self.doTakeScreenshot(currentAsset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, playerTime: playerTime1)
                
               i -= 1
            }
            
            
            // let twoFrame = CMTimeMakeWithSeconds(0.2, playerTime!.timescale);
             self.doTakeScreenshot(currentAsset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, playerTime: playerTime!)
            
            
            i = Int(0)
            
            while(i < numBursts) {
                
                let oneFrame = CMTimeMakeWithSeconds((Double(i) * interval), playerTime!.timescale);
                
                let playerTime1 = CMTimeAdd(playerTime!, oneFrame);
                
                self.doTakeScreenshot(currentAsset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, playerTime: playerTime1)
                
                i += 1
            }

            }
            
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                self.doTakeScreenshot(currentAsset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, playerTime: playerTime!)
            }
        }
    }
    
    
    func doTakeScreenshot(currentAsset: AVAsset, playerTime: CMTime ) {
        
        let maxTime = currentAsset.duration
        
        if(playerTime < kCMTimeZero && playerTime > maxTime) {
            return
        }
        print("Taking Screenshot");
        
        
        
        DispatchQueue.main.async {
            self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: playerTime)
            
            self.savingScreenShotSpinner.isHidden = false
            self.savingScreenShotSpinner.startAnimation(nil)
        }
        
        
                var playerWasPlaying = false
        
        if(self.appDelegate.videoPlayerViewController?.playerView.player?.isPlaying)! {
            
            self.appDelegate.videoPlayerViewController?.playerView.player?.pause()
            playerWasPlaying = true
            
        }
        
        self.trimOffset = CMTimeGetSeconds(playerTime)
        
        let newDate = getScreenShotDate(originalFile: self.nowPlayingURLString)
        
        
        if(self.appDelegate.screenshotPreview) {
            // THIS MUST HAPPEN FIRST
            DispatchQueue.main.async {
                self.savingScreenShotSpinner.stopAnimation(nil)
                self.savingScreenShotSpinner.isHidden = true
                
            }
            // print("Screen shot at: \(String(describing: playerTime))")
            
            self.appDelegate.screenshotViewController.takeScreenshot(asset: currentAsset, currentTime: playerTime, preview: true, modificationDate: newDate)
            
        } else {
            // print("Screen shot at: \(String(describing: playerTime))")
            self.appDelegate.screenshotViewController.takeScreenshot(asset: currentAsset, currentTime: playerTime, preview: false, modificationDate: newDate)
            if(playerWasPlaying) {
                DispatchQueue.main.async {
                    self.savingScreenShotSpinner.stopAnimation(nil)
                    self.savingScreenShotSpinner.isHidden = true
                    // self.appDelegate.videoPlayerViewController?.playerView.player?.play()
                    self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: playerTime)
                    
                }
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
            
        }
    }
    
    
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    
    @IBAction func shareAirdropVideo(sender: AnyObject?) {
        let videoURL = self.currentVideoURL
        let shareItems: NSArray? = NSArray(object: videoURL!)
        let service = NSSharingService(named: NSSharingServiceNameSendViaAirDrop)!
        service.perform(withItems: shareItems as! [Any])
        service.delegate = self.sharingDelegate
        
    }
    
    @IBAction func shareFacebook(sender: AnyObject?) {
        let videoURL = self.currentVideoURL
        let shareItems: NSArray? = NSArray(object: videoURL!)
        let picker = NSSharingServicePicker.init(items: shareItems as! [Any])
        picker.show(relativeTo: sender!.bounds, of: sender as! NSView, preferredEdge: NSRectEdge.minY)
    }
    
    
}
