//
//  videoControlsController.swift
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

class VideoPlayerControllsController: NSViewController, NSUserNotificationCenterDelegate {
    
    var notificationCenter: NSUserNotificationCenter!

    
    // Screenshotting
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
    var burstInProgress = false
    
    @IBOutlet weak var markChapterButton: NSButton!

    
    // Metadata
    
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
    
    @IBOutlet var saveFilePreserveDatesButton: NSButton!
    @IBOutlet var screenshotPreserveClipNameButton: NSButton!
    
    @IBOutlet var videoRateSlider: NSSlider!
    @IBOutlet var playerRateResetButton: NSButton!
    @IBOutlet var playerRateLabel: NSTextField!
    
    
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
        DispatchQueue.main.async {
            self.saveTrimmedClipView.isHidden = true
            self.saveTrimmedVideoButton.isHidden = true
            // self.savingScreenShotMessageBox.isHidden = true
        }
        
        let tapGesture = NSClickGestureRecognizer(target: self, action: #selector(handlePlayerLabelClick))
        self.playerTimerLabel.addGestureRecognizer(tapGesture)
        
        self.appDelegate.videoControlsController = self
        
        self.setupControls()
        
        self.notificationCenter = NSUserNotificationCenter.default
        self.notificationCenter.delegate = self
        
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        self.setupControls()
    }

    func setupControls() {
        DispatchQueue.main.async {
            if(self.appDelegate.appSettings.screenShotBurstEnabled) {
                self.screenShotBurstEnabledButton.state = 1
            } else {
                self.screenShotBurstEnabledButton.state = 0
            }
            
            
            if(self.appSettings.screenshotSound) {
                self.screenshotSoundButton.state = 1
            } else {
                self.screenshotSoundButton.state = 0
            }
            
            
            if(self.appSettings.screenshotPreview) {
                self.screenShotPreviewButton.state = 1
            } else {
                self.screenShotPreviewButton.state = 0
            }
        }
    }
    
    func startTimer() {
        // DispatchQueue.main.async {
        if(self.playerTimer == nil) {
            //print("Launching timer");
            self.playerTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector:#selector(self.updateTimerLabel), userInfo:nil, repeats: true)
        }
        // }
    }
    
    
    func stopTimer() {
        // DispatchQueue.main.async {
        if(self.playerTimer != nil) {
            self.playerTimer.invalidate()
            self.playerTimer = nil
        }
        // }
    }
    
    func updateTimerLabel() {
        let cur = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
        
        let durationSeconds = CMTimeGetSeconds((cur)!)
        
        let (h,m,s,_) = self.secondsToHoursMinutesSeconds(seconds: Int((durationSeconds)))
        
        DispatchQueue.main.async {
            
            self.playerTimerLabel?.stringValue = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
            
            self.currentFrameLabel?.stringValue = String(format: "%02f", durationSeconds)
        }
    }
    
    
    
    @IBAction func rateSliderChanged(_ sender: NSSlider) {
        // let slider = sender as! NSSlider
        // print(sender.doubleValue)
        self.appDelegate.videoPlayerViewController?.videoRate = sender.doubleValue
        
        self.appDelegate.videoPlayerViewController?.playerView.player?.rate = Float((self.appDelegate.videoPlayerViewController?.videoRate)!)
        
        DispatchQueue.main.async {
            self.playerRateLabel.stringValue = String(format: "%02f", sender.doubleValue)
        }
    }
    
    
    @IBAction func rateReset(_ sender: NSButton) {
        // let slider = sender as! NSSlider
        self.appDelegate.videoPlayerViewController?.videoRate = 1.0
        self.appDelegate.videoPlayerViewController?.playerView.player?.rate = Float((self.appDelegate.videoPlayerViewController?.videoRate)!)
        self.videoRateSlider.doubleValue = 1.0
        
        DispatchQueue.main.async {
            self.playerRateLabel.stringValue = String(format: "%02d", 1.0)
        }
    }
    
    
    func handlePlayerLabelClick() {
        // print("Play Pause")
        self.appDelegate.videoPlayerViewController?.playPause()
    }
    
    // Play / Pause / Increment / Decrement
    
    @IBAction func frameDecrement(_ sender: AnyObject?) {
        
        // if(  self.appDelegate.videoPlayerViewController?.playerItem)
        if(self.appDelegate.videoPlayerViewController?.playerView.player != nil) {
            self.appDelegate.videoPlayerViewController?.playerView.player?.pause()
            let currentTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
            let oneFrame = CMTimeMakeWithSeconds(1.0 / 29.97, currentTime!.timescale);
            
            let previousFrame = CMTimeSubtract(currentTime!, oneFrame);
            DispatchQueue.main.async {
                
                self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: previousFrame, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
                    self.updateTimerLabel()
                })
            }
        }
        
    }
    
    @IBAction func frameIncrement(_ sender: AnyObject?) {
        if(self.appDelegate.videoPlayerViewController?.playerView.player != nil) {
            let currentTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
            self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
            let oneFrame = CMTimeMakeWithSeconds(1.0 / 29.97, currentTime!.timescale);
            let nextFrame = CMTimeAdd(currentTime!, oneFrame);
            DispatchQueue.main.async {
                
                self.appDelegate.videoPlayerViewController?.playerView?.player?.seek(to: nextFrame, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
                    self.updateTimerLabel()
                })
            }
        }
    }
    
    // Video Chapters
    
    
    @IBAction func markChapter(_ sender: AnyObject) {
        
        let chapterMarkTime = self.appDelegate.videoPlayerViewController?.player.currentTime()
        
        self.appDelegate.videoDetailsViewController.addChapterMarker(url: self.currentVideoURL!, time: chapterMarkTime!)
        
        print("Chapter marked \(String(describing: chapterMarkTime))")
        
    }
    
    @IBAction func showVideoInfoWindow(_ sender: AnyObject) {
            print("Show the window punk!")
        self.appDelegate.splitViewController?.showVideoDetails()
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
            // print("Fuck that file exists..")
            let incrementer = "00000"
            self.clippedVideoName = self.appSettings.saveDirectoryName + " - Clip " + increment + " - " + incrementer + ".MOV"
            self.clippedVideoNameFull = self.clippedVideoPathFull + "/" + self.clippedVideoName
            self.clippedVideoNameFullURL = self.clippedVideoNameFull.replacingOccurrences(of: " ", with: "%20")
            
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
            self.appDelegate.videoPlayerViewController?.playPause()
            
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
            self.appDelegate.videoPlayerViewController?.playPause()
        }
        
        self.startTrimming()
    }
    
    func startTrimming() {
        self.userTrimmed = true
        self.clippedVideoPath = self.getClippedVideoPath(_videoPath: " ")
        
        DispatchQueue.main.async {
            self.saveTrimmedVideoButton.isHidden = false
            self.cancelTrimmedVideoButton.isHidden = false
            self.cancelTrimmedVideoButton.isEnabled = true
            self.saveTrimmedVideoButton.isEnabled = true
        }
        self.calculateClipLength()
        self.setupAvExportTrimmedClip()
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60, (seconds % 36000) % 60)
    }
    
    func calculateClipLength() {
        if(self.appDelegate.videoPlayerViewController!.playerIsReady) {
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
                
                DispatchQueue.main.async {
                    self.videoLengthLabel?.stringValue = String(format: "%02d", h) + "h:" + String(format: "%02d", m) + "m:" + String(format: "%02d", s) + "s"
                }
            } else {
                DispatchQueue.main.async {
                    self.calculateClipLength()
                    
                    self.videoLengthLabel?.stringValue = "00:00:0000"
                }
            }
            
        } else {
            self.videoLengthLabel?.stringValue = "00:00:0000"
        }
       
        
    }
    
    func doTheTrim() {
        if(self.appDelegate.videoPlayerViewController?.playerView.canBeginTrimming)! {
            if(!self.isTrimming) {
                
                if(self.appSettings.mediaBinIsOpen) {
                    self.appDelegate.mediaBinCollectionView.hideMediaBin()
                }
                
                self.isTrimming = true
                self.appDelegate.videoPlayerViewController?.playerView.beginTrimming { result in
                    if result == .okButton {
                        self.startTrimming()
                    } else {
                        self.cancelTrimmedClip(self)
                        
                        //if(self.appSettings.mediaBinIsOpen) {
                            self.appDelegate.mediaBinCollectionView.unHideMediaBin()
                        //}
                        
                    }
                }
            }
        } else {
            print("CANNOT BEGIN TRIMMING. DAMMIT")
        }
        
    }
    
    
    @IBAction func setPreserveOriginalDates(_ sender: AnyObject) {
        if(self.saveFilePreserveDatesButton.state == 0) {
            self.clippedItemPreserveFileDates = false
            UserDefaults.standard.setValue(0, forKey: "clippedItemPreserveFileDates")
            
            // self.appDelegate.appSettings.screenshotPreserveVideoDate = true
            
        }
        
        if(self.saveFilePreserveDatesButton.state == 1) {
            self.clippedItemPreserveFileDates = true
            UserDefaults.standard.setValue(1, forKey: "clippedItemPreserveFileDates")
        }
    }
    
    @IBAction func setScreenShotBurstEnable(_ sender: AnyObject) {
        // print("Screenshot Burst State: \(self.screenShotBurstEnabledButton.state)")
        
        
        if(self.screenShotBurstEnabledButton.state == 0) {
            // self.appSettings.screenShotBurstEnabled = false
            self.appDelegate.appSettings.screenShotBurstEnabled = false
        }
        
        if(self.screenShotBurstEnabledButton.state == 1) {
            self.appDelegate.appSettings.screenShotBurstEnabled = true
        }
        
        self.appDelegate.saveProject()
        
        
    }
    
    @IBAction func setLoadNewClipItem(_ sender: AnyObject) {
        if(self.saveClipLoadNewItemCheckbox.state == 0) {
            self.clippedItemLoadNewItem = false
            //  UserDefaults.standard.setValue(0, forKey: "clippedItemLoadNewItem")
        }
        
        if(self.saveClipLoadNewItemCheckbox.state == 1) {
            self.clippedItemLoadNewItem = true
            UserDefaults.standard.setValue(1, forKey: "clippedItemLoadNewItem")
        }
        
        self.appDelegate.saveProject()
        
        
    }
    
    
    @IBAction func setPreviewScreenshot(_ sender: AnyObject) {
        if(self.screenShotPreviewButton.state == 0) {
            self.appDelegate.appSettings.screenshotPreview = false
        }
        
        if(self.screenShotPreviewButton.state == 1) {
            self.appDelegate.appSettings.screenshotPreview = true
        }
        self.appDelegate.saveProject()
    }
    
    
    
    @IBAction func setScreenShotPreserveClipName(_ sender: AnyObject) {
        
        if(self.screenshotPreserveClipNameButton.state == 0) {
            self.appDelegate.appSettings.screenshotPreserveVideoName = false
        }
        
        if(self.screenshotPreserveClipNameButton.state == 1) {
            self.appDelegate.appSettings.screenshotPreserveVideoName = true
        }
        
        self.appDelegate.saveProject()
        
    }
    
    @IBAction func setScreenShotSound(_ sender: AnyObject) {
        if(self.screenshotSoundButton.state == 0) {
            self.appDelegate.appSettings.screenshotSound = false
        }
        
        if(self.screenshotSoundButton.state == 1) {
            self.appDelegate.appSettings.screenshotSound = true
        }
        
        self.appDelegate.saveProject()
        
    }
    
    
    @IBAction func cancelTrimmedClip(_ sender: AnyObject?) {
        self.isTrimming = false;
        
        DispatchQueue.main.async {
            self.saveTrimmedClipView.isHidden = true
            self.cancelTrimmedVideoButton.isHidden = true
            self.userTrimmed = false
            self.saveTrimmedVideoButton.isHidden = true
        }
        
        self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime = kCMTimeZero
        self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime = (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.duration)!
        
        if(self.exportSession.status == .exporting) {
            print("Cancelling Export!");
            self.exportSession.cancelExport();
        }
    }
    
    @IBAction func openScreenshotSettings(sender : AnyObject) {
        self.appDelegate.screenshotSettingsWindowController = ScreenshotSettingsWindowController()
        self.appDelegate.screenshotSettingsWindowController.window?.makeKeyAndOrderFront(self)
    }
    
    func setupAvExportTrimmedClip() {
        DispatchQueue.main.async {
            self.saveTrimmedClipView.isHidden = false
            self.saveTrimmedVideoButton.isEnabled = true
            self.cancelTrimmedVideoButton.isEnabled = true
        }
        
        self.exportSession = AVAssetExportSession(asset: (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.asset)!, presetName: AVAssetExportPresetHighestQuality)!
        
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie
        self.exportSession.outputURL = URL(string: self.clippedVideoNameFullURL)// Output URL
        
        let startTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime
        let endTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime
        let timeRange = CMTimeRangeFromTimeToTime(startTime!, endTime!)
        
        self.trimOffset = CMTimeGetSeconds(startTime!)
        
        self.exportSession.timeRange = timeRange
        
        self.clipFileSizeVar = self.exportSession.estimatedOutputFileLength
        
        DispatchQueue.main.async {
            self.clipFileSizeLabel.stringValue = String(format: "%2d", self.clipFileSizeVar);
        }
    }
    
    @IBAction func saveTrimmedClip(_ sender: AnyObject?) {
        print ("Saving Trimmed Clip to the queue!!");
        
        self.saveTrimmedVideoButton.isEnabled = false
        self.cancelTrimmedVideoButton.isEnabled = true
        
        do {
            try FileManager.default.createDirectory(atPath: self.clippedVideoPath, withIntermediateDirectories: true, attributes: nil)
        } catch _ as NSError {
            print("Error while creating a folder.")
        }
        
        
        func finishSave(_ err: Bool, url: URL) {
            DispatchQueue.main.async {
                
                if(!err) {
                    saveClippedFileCompleted()
                    
                    let notification = NSUserNotification()
                    
                    notification.identifier = "clipTrim\(UUID().uuidString)"
                    notification.title = "Video Clip Trim Saved!"
                    notification.informativeText = url.lastPathComponent.replacingOccurrences(of: "%20", with: " ")
                    
                    notification.soundName = NSUserNotificationDefaultSoundName
                    notification.notificationUrl = url.absoluteString
                    notification.hasActionButton = true
                    notification.actionButtonTitle = "View"
                    
                    notification.setValue(true, forKey: "_showsButtons")
                    
                    var actions = [NSUserNotificationAction]()
                    
                    let action1 = NSUserNotificationAction(identifier: "viewNow", title: url.absoluteString)
                    
                    let action2 = NSUserNotificationAction(identifier: "openInFinder", title: "Open in Quicktime")
                    
                    actions.append(action1)
                    actions.append(action2)
                    
                    notification.additionalActions = actions
                    
                    self.notificationCenter.deliver(notification)
  
                } else {
                    saveClippedFileFailed()
                    let myPopup: NSAlert = NSAlert()
                    DispatchQueue.main.async {
                        myPopup.messageText = "Clip Trim Failed"
                        myPopup.informativeText = "Something went wrong. Dispatching Monkeys to find out why."
                        myPopup.alertStyle = NSAlertStyle.warning
                        myPopup.addButton(withTitle: "OK")
                        myPopup.runModal()
                    }
                }
            }
        }
        
        func saveClippedFileCompleted() {
            print("Session Completed")
            self.saveTrimmedVideoButton.isHidden = true
            self.trimmedClipNewLabel.isHidden = true
            self.trimmedClipNewLabel.stringValue = ""
            self.cancelTrimmedVideoButton.isHidden = true
            
            if(self.clippedItemPreserveFileDates) {
                self.setFileDate(originalFile: (self.appDelegate.videoPlayerViewController?.nowPlayingURL.path)!, newFile: self.clippedVideoNameFull.replacingOccurrences(of: "file://", with: ""))
            }
            
            DispatchQueue.main.async {
                self.isTrimming = false
            }
            
            self.appDelegate.appSettings.mediaBinUrls.append(URL(string: self.clippedVideoNameFullURL)!)
            self.appDelegate.saveProject()
        }
        
        func saveClippedFileFailed() {
            print("Session FAILED")
            DispatchQueue.main.async {
                self.saveTrimmedVideoButton.isEnabled = true
            }
        }
        
        func saveClippedFileUnknown() {
            print("I don't know..");
        }
        
        let outputUrl = URL(string: (self.clippedVideoNameFullURL.copy() as! String))
        let asset = AVAsset(url: (self.appDelegate.videoPlayerViewController?.nowPlayingURL)!)
        
        let startTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.reversePlaybackEndTime
        let endTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.forwardPlaybackEndTime
        let timeRange = CMTimeRangeFromTimeToTime(startTime!, endTime!)
        
        let workerItem: MediaQueueWorkerItem!
        workerItem = MediaQueueWorkerItem()
        
        let clipTrimWorkerItem = DispatchWorkItem {
            workerItem.inProgress = true
            workerItem.outputUrl = outputUrl
            workerItem.title = "Video Clip Trim In Progress!"
            
            let builder = ClipTrimBuilder(asset: asset, url: outputUrl!)
            
            let framerate = self.appSettings.frameRates[5]
            let size = self.appSettings.videoSizes[7]
            
            builder.build(timeRange: timeRange, frameRate: Int32(framerate), outputSize: size, { progress in
                workerItem.inProgress = true
                workerItem.percent = (progress.fractionCompleted * 100.0)
            }, success: { url in
                workerItem.outputUrl = url
                workerItem.workerStatus = true
                workerItem.inProgress = false
                DispatchQueue.main.async {
                    finishSave(false, url: url)
                }
            }, failure: { error in
                print("ERROR \(error)")
                workerItem.workerStatus = false
                workerItem.inProgress = false
                workerItem.failed = true
                DispatchQueue.main.async {
                    finishSave(true, url: outputUrl!)
                }
            })
        }
        
        let queue = DispatchQueue.global(qos: self.appSettings.dispatchQueue)
        
        self.appDelegate.mediaQueue.queue.append(workerItem)
        
        queue.async(execute: clipTrimWorkerItem)
        
        clipTrimWorkerItem.notify(queue: DispatchQueue.main) {
            
            // print("percent = ", percent)
            print("Worker launched... ")
        }
        
        self.saveTrimmedVideoButton.isHidden = true
        self.trimmedClipNewLabel.isHidden = true
        self.trimmedClipNewLabel.stringValue = ""
        self.cancelTrimmedVideoButton.isHidden = true
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
    
    
    func takeScreeShotFromKeyboard() {
        //if(self.playerIsReady) {
        self.takeScreenshot("" as AnyObject)
        //}
    }
    
    func takeBurstScreenshotFromKeyboard() {
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
    
    
    func messageBox(hidden: Bool) {
        DispatchQueue.main.async {
            if(hidden == true) {
                //print("Unhiding")
                self.appDelegate.videoPlayerViewController?.playerMessageBox.isHidden = true
            } else {
                //print("Hiding")
                
                self.appDelegate.videoPlayerViewController?.playerMessageBox.isHidden = false
            }
        }
    }
    
    func messageBoxLabel(string: String) {
        DispatchQueue.main.async {
            self.appDelegate.videoPlayerViewController?.playerMessageBoxLabel.stringValue = string
        }
        
    }
    
    @IBAction func takeScreenshot(_ sender: AnyObject?) {
        
        if(self.appDelegate.appSettings.screenshotPreview && self.burstInProgress == true) {
            return
        } else {
            
            var playerWasPlaying = false
            
            self.messageBoxLabel(string: "Screen Shot Starting...")
            self.messageBox(hidden: false)
            if(self.appDelegate.videoPlayerViewController?.playerView.player?.isPlaying)! {
                self.appDelegate.videoPlayerViewController?.playerView.player?.pause()
                playerWasPlaying = true
            }
            
            let playerTime = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
            
            let numBursts = Int(self.appSettings.screenshotFramesAfter) + Int(self.appSettings.screenshotFramesBefore)
            let interval = self.appSettings.screenshotFramesInterval
            var burstsTaken = 0

            if(self.appDelegate.appSettings.screenShotBurstEnabled) {
                if(self.appDelegate.appSettings.screenshotPreview) {
                    // Live burst mode, show the user in real time...
                    self.burstInProgress = true
                    
                    var i = Int(self.appSettings.screenshotFramesBefore)
                    
                    while(i > 0) {
                        let oneFrame = CMTimeMakeWithSeconds((Double(i) * interval), playerTime!.timescale);
                        
                        let playerTime1 = CMTimeSubtract(playerTime!, oneFrame);
                        self.messageBoxLabel(string: "Screen Shot Burst: \(burstsTaken + 1)")
                        self.doTakeScreenshot(currentAsset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, playerTime: playerTime1)
                        
                        burstsTaken += 1
                        
                        i -= 1
                    }
                    
                    i = Int(0)
                    var playerTime1: CMTime!
                    
                    while(i < Int(self.appSettings.screenshotFramesAfter)) {
                        let oneFrame = CMTimeMakeWithSeconds((Double(i) * interval), playerTime!.timescale);
                        
                        playerTime1 = CMTimeAdd(playerTime!, oneFrame);
                        
                        // do this before calling takeScreenshot
                        if(burstsTaken + 1 == numBursts) {
                            self.burstInProgress = false
                        }
                        
                        self.messageBoxLabel(string: "Screen Shot Burst: \(burstsTaken + 1)")
                        self.doTakeScreenshot(currentAsset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, playerTime: playerTime1)
                        
                        burstsTaken += 1
                        
                        i += 1
                    }
                    
                    if(playerWasPlaying) {
                        DispatchQueue.main.async {
                            self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: playerTime1!, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
                                self.updateTimerLabel()
                                
                                self.appDelegate.videoPlayerViewController?.playerView.player?.rate = Float((self.appDelegate.videoPlayerViewController?.videoRate)!)
                                
                            })
                        }
                    }
                    
                    self.burstInProgress = false
                    self.messageBox(hidden: true)
                    
                    DispatchQueue.main.async {
                        self.appDelegate.mediaBinCollectionView.reloadContents()
                    }

                    
                } else {
                    // Background mode... this is the shit!
                    self.messageBoxLabel(string: "Screen Shot Burst Queued...")
                    self.messageBox(hidden: false)
 
                    let outputUrl = self.appDelegate.screenshotViewController.getScreenshotPath(startTime: playerTime!, assetURL: self.appDelegate.videoPlayerViewController?.nowPlayingURL)
                    
                    let asset = AVAsset(url: (self.appDelegate.videoPlayerViewController?.nowPlayingURL)!)
                    
                    let workerItem: MediaQueueWorkerItem!
                    workerItem = MediaQueueWorkerItem()
                    
                    let frameBurstWorkerItem = DispatchWorkItem {
                        workerItem.inProgress = true
                        workerItem.outputUrl = outputUrl
                        workerItem.title = "Frame Burst In Progress!"
   
                        let builder = VideoFrameBurstBuilder(asset: asset, url: outputUrl!)
                        
                        let size = self.appSettings.videoSizes[7]
                        
                        builder.build(
                            startTime: (self.appDelegate.videoPlayerViewController?.playerView.player?.currentItem?.currentTime())!,
                            assetUrl: self.appDelegate.videoPlayerViewController?.nowPlayingURL!,
                            interval: self.appDelegate.appSettings.screenshotFramesInterval,
                            framesBefore: self.appDelegate.appSettings.screenshotFramesBefore,
                            framesAfter: self.appDelegate.appSettings.screenshotFramesAfter,
                            preserveName: self.appDelegate.appSettings.screenshotPreserveVideoName,
                            preserveDate: self.appDelegate.appSettings.screenshotPreserveVideoDate,
                            preserveLocation: self.appDelegate.appSettings.screenshotPreserveVideoLocation,
                            outputSize: size,
                        { progress, url in
                            
                            // print("burst progress: \(progress.fractionCompleted)")
                            
                            workerItem.inProgress = true
                            workerItem.percent = (progress.fractionCompleted * 100.0)
                            workerItem.outputUrl = url
                        }, success: { url in
                            //print("burst success: \(url)")
                            workerItem.outputUrl = url
                            workerItem.workerStatus = true
                            workerItem.inProgress = false
                            DispatchQueue.main.async {
                                finishBurstSave(false, url: url)
                            }
                        }, failure: { error in
                            print("burst ERROR \(error)")
                            workerItem.workerStatus = false
                            workerItem.inProgress = false
                            workerItem.failed = true
                            DispatchQueue.main.async {
                                finishBurstSave(true, url: outputUrl!)
                            }
                        })
                    }
                    
                    let queue = DispatchQueue.global(qos: self.appSettings.dispatchQueue)
                    
                    self.appDelegate.mediaQueue.queue.append(workerItem)
                    
                    queue.async(execute: frameBurstWorkerItem)
                    
                    frameBurstWorkerItem.notify(queue: DispatchQueue.main) {
                        // print("percent = ", percent)
                        print("Worker launched... ")
                    }
                    
                    self.messageBox(hidden: true)
                    
                    DispatchQueue.main.async {
                        if(playerWasPlaying) {
                           self.appDelegate.videoPlayerViewController?.playerView.player?.rate = Float((self.appDelegate.videoPlayerViewController?.videoRate)!)
                            playerWasPlaying = false
                        }
                        
                    }

                    
                    func finishBurstSave(_ err: Bool, url: URL) {
                        DispatchQueue.main.async {
                            
                            if(!err) {
                                // saveClippedFileCompleted()
                                let notification = NSUserNotification()
                                
                                notification.identifier = "frameBurst\(UUID().uuidString)"
                                notification.title = "Video Frame Burst Saved!"
                                notification.informativeText = url.lastPathComponent.replacingOccurrences(of: "%20", with: " ")
                                
                                notification.soundName = NSUserNotificationDefaultSoundName
                                notification.notificationUrl = url.absoluteString
                                notification.hasActionButton = true
                                notification.actionButtonTitle = "View"
                                
                                notification.setValue(true, forKey: "_showsButtons")
                                
                                var actions = [NSUserNotificationAction]()
                                
                                let action1 = NSUserNotificationAction(identifier: "viewNow", title: url.absoluteString)
                                
                                let action2 = NSUserNotificationAction(identifier: "openInFinder", title: "Open in Quicktime")
                                
                                actions.append(action1)
                                actions.append(action2)
                                
                                notification.additionalActions = actions
                                
                                self.notificationCenter.delegate = self
                                self.notificationCenter.deliver(notification)
                                
                            } else {
                                // saveClippedFileFailed()
                                let myPopup: NSAlert = NSAlert()
                                DispatchQueue.main.async {
                                    myPopup.messageText = "Frame Burst Failed"
                                    myPopup.informativeText = "Something went wrong. Dispatching Monkeys to find out why."
                                    myPopup.alertStyle = NSAlertStyle.warning
                                    myPopup.addButton(withTitle: "OK")
                                    myPopup.runModal()
                                }
                            }
                        }
                    }
                }
                
                
            } else {
                DispatchQueue.main.async {
                    self.messageBoxLabel(string: "Screen Shot Taken!")
                }
                
                self.doTakeScreenshot(currentAsset: (self.appDelegate.videoPlayerViewController?.currentAsset)!, playerTime: playerTime!)
                
                if(playerWasPlaying) {
                    DispatchQueue.main.async {
                        self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: playerTime!, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
                            self.updateTimerLabel()
                            
                            self.appDelegate.videoPlayerViewController?.playerView.player?.rate = Float((self.appDelegate.videoPlayerViewController?.videoRate)!)
                        })
                    }
                }
                
                self.burstInProgress = false
                self.messageBox(hidden: true)
                
                if(self.appDelegate.appSettings.screenshotPreview == false) {
                    
                }
                
                DispatchQueue.main.async {
                    self.appDelegate.mediaBinCollectionView.reloadContents()
                }
            }
        }
    }
    
    
    func doTakeScreenshot(currentAsset: AVAsset, playerTime: CMTime ) {
        messageBox(hidden: false)
        
        let maxTime = currentAsset.duration
        
        if(playerTime < kCMTimeZero && playerTime > maxTime) {
            messageBox(hidden: true)
            return
        }
        
        print("Taking Screenshot");
        
        DispatchQueue.main.async {
            self.appDelegate.videoPlayerViewController?.playerView.player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { (Bool) in
                self.updateTimerLabel()
            })
        }
        
        self.trimOffset = CMTimeGetSeconds(playerTime)
        
        let newDate = getScreenShotDate(originalFile: (self.appDelegate.videoPlayerViewController?.nowPlayingURL.absoluteString)!)
        
        
        if(self.appSettings.screenshotPreview) {
            messageBox(hidden: false)
            
            self.appDelegate.screenshotViewController.takeScreenshot(asset: currentAsset, assetURL: self.appDelegate.videoPlayerViewController?.nowPlayingURL, currentTime: playerTime, preview: true, modificationDate: newDate)
            
        } else {
            // print("Screen shot at: \(String(describing: playerTime))")
            
            self.appDelegate.screenshotViewController.takeScreenshot(asset: currentAsset, assetURL: self.appDelegate.videoPlayerViewController?.nowPlayingURL, currentTime: playerTime, preview: false, modificationDate: newDate)
            
            messageBox(hidden: false)
            
        }
        
    }
    
    func showNotification(messageType: String, customMessage: String) -> Void {
        //DispatchQueue.global(qos: .userInitiated).async {
            if(messageType == "videoTrimComplete") {
                // print("Message Type VIDEO TRIM COMPLETE: " + messageType);
                let notification = NSUserNotification()
                notification.title = "Video Trimming Complete"
                notification.informativeText = "Your clip has been saved. " + customMessage.replacingOccurrences(of: "%20", with: " ")
                
                notification.soundName = NSUserNotificationDefaultSoundName
                self.appDelegate.notificationCenter.deliver(notification)
                
            }
            
        // }
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
    
    
    
    
    // Notifications
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) {
            
        case .actionButtonClicked:
            self.appDelegate.rightPanelSplitViewController?.showVideoSplitView()
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(url: URL(string: notification.notificationUrl!)!)
            
        case .contentsClicked:
            self.appDelegate.rightPanelSplitViewController?.showVideoSplitView()
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(url: URL(string: notification.notificationUrl!)!)
        default:
            break
        }
    }
    
}
