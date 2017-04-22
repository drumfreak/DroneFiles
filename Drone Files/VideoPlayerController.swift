//
//  VideoPlayer.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation

import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz

class VideoPlayerViewController: NSViewController {
    
    @IBOutlet var VideoEditView: NSView!
    
    @IBOutlet weak var screenshotViewController: ScreenshotViewController!
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var editorTabViewContrller: EditorTabViewController!
    @IBOutlet weak var mainViewController: ViewController!
    
    
    // Video Trimming
    @IBOutlet var saveNewItemPreserveDate: NSButton!
    @IBOutlet var saveClipLoadNewItemCheckbox: NSButton!
    @IBOutlet var saveTrimmedClipView: NSView!
    // @IBOutlet weak var exportSession: AVAssetExportSession!
    @IBOutlet weak var clipTrimTimer: Timer!
    @IBOutlet weak var playerTimer: Timer!
    @IBOutlet weak var saveTrimmedVideoButton: NSButton!
    @IBOutlet weak var cancelTrimmedVideoButton: NSButton!
    @IBOutlet weak var clipFileSizeLabel: NSTextField!
    var clipFileSizeVar = Int64(0)
    let sizeFormatter = ByteCountFormatter()
    var userTrimmed = false
    var isTrimming = false
    var clippedItemPreserveFileDates = true
    var clippedItemLoadNewItem = true
    var startPlayingVideo = true
    var playerIsReady = false
    // Screenshotting
    var screenShotPreview = true
    var trimOffset = 0.00
    
    @IBOutlet var screenShotPreviewButton: NSButton!
    
    
    // Video Player Stuff
    @IBOutlet var playerItem: AVPlayerItem!
    var currentVideoURL: URL!
    @IBOutlet var originalPlayerItem: AVPlayerItem!
    @IBOutlet var player: AVPlayer!
    var nowPlayingURLString: String!
    var exportSession: AVAssetExportSession!
    var nowPlayingURL: URL!
    @IBOutlet weak var nowPlayingFile: NSTextField!
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var trimmedClipNewLabel: NSTextField!
    @IBOutlet weak var trimmedClipNewPathLabel: NSTextField!
    @IBOutlet weak var videoLengthLabel: NSTextField!
    
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    var currentAsset: AVAsset!
    
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
    
    @IBOutlet var savingScreenShotSpinner: NSProgressIndicator!
    @IBOutlet var savingScreenShotMessageBox: NSView!
    
    var playerViewControllerKVOContext = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Video Player Controller Loaded")
        
        self.VideoEditView.isHidden = true
        self.clipTrimProgressBar.isHidden = true
        self.saveTrimmedClipView.isHidden = true
        self.saveTrimmedVideoButton.isHidden = true
        self.screenShotPreviewButton.isEnabled = self.screenShotPreview
        // self.savingScreenShotMessageBox.isHidden = true
        self.savingScreenShotSpinner.isHidden = true
//        
        addObserver(self, forKeyPath: #keyPath(playerItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(playerItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        
    }
    
    
    // Video Clipping
    func getClippedVideosIncrement(_folder: String) -> String {
        var incrementer = "00"
        if FileManager.default.fileExists(atPath: self.clippedVideoPath) {
            // print("url is a folder url")
            // lets get the folder files
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.mainViewController.videoClipsFolder)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%02d", files.count)
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func getClippedVideoPath(_videoPath : String) -> String {
        self.clippedVideoPathFull = self.mainViewController.videoClipsFolder.replacingOccurrences(of: "%20", with: " ")
        self.clippedVideoPath = self.clippedVideoPathFull.replacingOccurrences(of: "file://", with: "")
        
        
        
        let increment = getClippedVideosIncrement(_folder: self.mainViewController.videoClipsFolder)
        
        self.clippedVideoName = self.mainViewController.saveDirectoryName + " - Clip " + increment + ".MOV"
        self.clippedVideoNameFull = self.clippedVideoPathFull + "/" + self.clippedVideoName
        self.clippedVideoNameFullURL = self.clippedVideoNameFull.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: self.clippedVideoNameFull.replacingOccurrences(of: "file://", with: "")) {
            print("Fuck that file exists..")
            let incrementer = "00000"
            self.clippedVideoName = self.mainViewController.saveDirectoryName + " - Clip " + increment + " - " + incrementer + ".MOV"
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
        if(!self.isTrimming) {
            doTheTrim()
        }
        
        let currentVideoTime = self.playerView.player?.currentTime()
        self.playerView.player?.currentItem?.reversePlaybackEndTime = currentVideoTime!
        
        if(self.playerView.player?.currentItem?.forwardPlaybackEndTime == kCMTimeInvalid) {
            // print("TRIMMED SKIPPING")
            self.playerView.player?.currentItem?.forwardPlaybackEndTime = (self.playerView.player?.currentItem?.duration)!
        }
        
        self.startTrimming();
        
        // self.playerView.player?.seek(to: currentVideoTime)
        if(self.playerView.player?.isPlaying == false) {
            self.playerView.player?.play()
        }
    }
    
    
    @IBAction func setTrimPointOut(_ sender: AnyObject) {
        if(!self.isTrimming) {
            doTheTrim()
        }
        
        let currentVideoTime = (self.playerView.player?.currentItem?.currentTime())!
        self.playerView.player?.seek(to: currentVideoTime)
        self.playerView.player?.currentItem?.forwardPlaybackEndTime = currentVideoTime
        
        if(self.playerView.player?.isPlaying == false) {
            self.playerView.player?.play()
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
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func calculateClipLength() {
        // print("Calling Calculate Clip Length")
        if(self.playerView.player?.currentItem?.forwardPlaybackEndTime == kCMTimeInvalid) {
            self.playerView.player?.currentItem?.forwardPlaybackEndTime = (self.playerView.player?.currentItem?.duration)!
        }
        
        if(self.playerView.player?.currentItem?.reversePlaybackEndTime == kCMTimeInvalid) {
            self.playerView.player?.currentItem?.reversePlaybackEndTime = kCMTimeZero
        }
        
        let difference = CMTimeSubtract((self.playerView.player?.currentItem?.forwardPlaybackEndTime)!, (self.playerView.player?.currentItem?.reversePlaybackEndTime)!)
        let durationSeconds = CMTimeGetSeconds(difference);
        
        if(durationSeconds > 0) {
            let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: Int(round(durationSeconds)))
            self.videoLengthLabel.stringValue = String(format: "%02d", h) + "h:" + String(format: "%02d", m) + "m:" + String(format: "%02d", s) + "s"
        } else {
            self.videoLengthLabel.stringValue = "00:00:0000"
        }
        
    }
    
    func doTheTrim() {
        if(self.playerView.canBeginTrimming) {
            if(!self.isTrimming) {
                self.isTrimming = true
                self.playerView.beginTrimming { result in
                    if result == .okButton {
                        self.startTrimming()
                    } else {
                        self.cancelTrimmedClip(self.playerView)
                    }
                }
            }
        } else {
            print("CANNOT BEGIN TRIMMING. DAMMIT")
        }
        
    }
    
    func playVideo(_url: URL, frame: CMTime, startPlaying: Bool) {
        print("Play Video function")
        if(startPlaying) {
            self.startPlayingVideo = true // passes off to after player is ready.
        }
        
        self.playerView.player = prepareToPlay(_url: _url, startTime: frame)
        // self.playerView.player?.seek(to: frame)
        // print("Play Video function")
        
    }
    
    // Video Player Setup and Play
    func prepareToPlay(_url: URL, startTime: CMTime) -> AVPlayer {
        
        let url = _url
        self.currentVideoURL = url
        let asset = AVAsset(url: url)
        let assetKeys = [
            "playable",
            "hasProtectedContent"
        ]
        self.currentAsset = asset
        self.playerView.showsFrameSteppingButtons = true
        self.playerView.showsSharingServiceButton = true
        self.playerView.showsFullScreenToggleButton = true
        //self.playerView.showCon
        
        let playerItem = AVPlayerItem(asset: asset,
                                      automaticallyLoadedAssetKeys: assetKeys)
        playerItem.reversePlaybackEndTime = kCMTimeZero
        playerItem.forwardPlaybackEndTime = playerItem.duration
        
        if(self.playerView.player?.currentItem! != nil) {
            //let previousItem = self.playerView.player?.currentItem!
            self.deallocObservers(playerItem: self.playerView.player!)
        }
        
        if(self.playerView.player == nil) {
            // print("player is nil")
            
            let player = AVPlayer(playerItem: playerItem)
            
            self.playerView.player = player
            
            // Register as an observer of the player item's status property
            self.playerView.player?.addObserver(self,
                                                forKeyPath: #keyPath(AVPlayerItem.status),
                                                options: [.old, .new],
                                                context: &playerViewControllerKVOContext)
            
            self.playerView.player?.addObserver(self,
                                                forKeyPath: #keyPath(AVPlayer.rate),
                                                options: [.old, .new],
                                                context: &playerViewControllerKVOContext)
        } else {
            // print("player IS NOT nil")
            // self.deallocObservers(player: (self.playerView.player?.currentItem!)!)
            
            let player = AVPlayer(playerItem: playerItem)
            
            // self.playerView.player? = nil
            self.playerView.player? = player
            self.playerView.player?.addObserver(self,
                                                forKeyPath: #keyPath(AVPlayerItem.status),
                                                options: [.old, .new],
                                                context: &playerViewControllerKVOContext)
            
            self.playerView.player?.addObserver(self,
                                                forKeyPath: #keyPath(AVPlayer.rate),
                                                options: [.old, .new],
                                                context: &playerViewControllerKVOContext)
//
//            
            // self.playerView.player?.replaceCurrentItem(with: playerItem)
        }
        
        
        
        self.calculateClipLength()
        
        return self.playerView.player!
    }
    
    func deallocObservers(playerItem: AVPlayer) {
        if(self.playerIsReady) {
            self.playerIsReady = false
            print("Deallocating Observers from playerItem")
            self.playerView.player?.pause()
            // self.playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            self.playerView.player?.removeObserver(self, forKeyPath: "status", context: &playerViewControllerKVOContext)
            // self.playerView.player?.replaceCurrentItem(with: nil)
        }
    }
    
    
    @IBAction func setPreserveOriginalDates(_ sender: AnyObject) {
        self.clippedItemPreserveFileDates = !self.clippedItemPreserveFileDates
        //print("Preserve Original Dates Clicked")
        //print("Preserve Original Dates Clicked \(self.clippedItemPreserveFileDates)")
    }
    
    @IBAction func setLoadNewClipItem(_ sender: AnyObject) {
        self.clippedItemLoadNewItem = !self.clippedItemLoadNewItem
        //print("Load New Clip Clicked \(self.clippedItemLoadNewItem)")
    }
    
    
    @IBAction func setPreviewScreenshot(_ sender: AnyObject) {
        self.screenShotPreview = !self.screenShotPreview
    }
    
    
    @IBAction func cancelTrimmedClip(_ sender: AnyObject?) {
        //print("Canceling Save Trimmed Clip");
        // let currentVideoTime = self.playerItem.currentTime()
        self.isTrimming = false;
        self.saveTrimmedClipView.isHidden = true
        self.cancelTrimmedVideoButton.isHidden = true
        self.userTrimmed = false
        self.saveTrimmedVideoButton.isHidden = true
        self.playerView.player?.currentItem?.reversePlaybackEndTime = kCMTimeZero
        self.playerView.player?.currentItem?.forwardPlaybackEndTime = (self.playerView.player?.currentItem?.duration)!
        
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
        self.flightNameVar = self.flightName.stringValue
        self.dateNameVar = self.dateField.stringValue
        
        self.exportSession = AVAssetExportSession(asset: (self.playerView.player?.currentItem?.asset)!, presetName: AVAssetExportPresetHighestQuality)!
        
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie
        self.exportSession.outputURL = URL(string: self.clippedVideoNameFullURL)// Output URL
        
        let startTime = self.playerView.player?.currentItem?.reversePlaybackEndTime
        let endTime = self.playerView.player?.currentItem?.forwardPlaybackEndTime
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
            
            print("Claaned up session");
            self.mainViewController.reloadFileList()
            
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
        
        print("TRIM OFFSET \(self.trimOffset)")
        
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        original = original.replacingOccurrences(of: "%20", with: " ");
        let date = Date()
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: original)
            let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            
            let newDate = Calendar.current.date(byAdding: .second, value: Int(self.trimOffset), to: modificationDate)
            
            print("Modification date: ", newDate!)
            return newDate!
            
        } catch let error {
            print("Error getting file modification attribute date: \(error.localizedDescription)")
            return date
        }
        // return date
    }
    
    @IBAction func takeScreenshot(_ sender: AnyObject?) {
        print("Taking Screenshot");
        self.savingScreenShotMessageBox.isHidden = true
        self.savingScreenShotSpinner.isHidden = false
        self.savingScreenShotSpinner.startAnimation(nil)
        
        let playerTime = self.playerView.player?.currentTime()
        
        var playerWasPlaying = false
        if(self.playerView.player?.isPlaying)! {
            self.playerView.player?.pause()
            playerWasPlaying = true
        }
        
        self.trimOffset = CMTimeGetSeconds((self.playerView.player?.currentTime())!)
        
        let newDate = getScreenShotDate(originalFile: self.nowPlayingURLString)
        
        
        if(self.screenShotPreview) {
            // THIS MUST HAPPEN FIRST
            self.savingScreenShotSpinner.stopAnimation(self)
            self.savingScreenShotSpinner.isHidden = true
            self.editorTabViewContrller.selectedTabViewItemIndex = 1
            print("Screen shot at: \(String(describing: playerTime))")
            self.screenshotViewController.takeScreenshot(asset: self.currentAsset, currentTime: playerTime!, preview: true, modificationDate: newDate)
        } else {
            print("Screen shot at: \(String(describing: playerTime))")
            self.screenshotViewController.takeScreenshot(asset: self.currentAsset, currentTime: playerTime!, preview: false, modificationDate: newDate)
            if(playerWasPlaying) {
                self.savingScreenShotSpinner.stopAnimation(self)
                self.savingScreenShotSpinner.isHidden = true
                self.playerView.player?.play()
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
    
    
    // Player stuff
    
    
    let timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        return formatter
    }()
    
    
    func handleErrorWithMessage(_ message: String?, error: Error? = nil) {
       //  print("Error occured with message: \(message), error: \(error).")
       //  print("Error occured with message: \(message?)")

//        let alertTitle = NSLocalizedString("alert.error.title", comment: "Alert title for errors")
//        let defaultAlertMessage = NSLocalizedString("error.default.description", comment: "Default error message when no NSError provided")
//        
//        let alert = UIAlertController(title: alertTitle, message: message == nil ? defaultAlertMessage : message, preferredStyle: UIAlertControllerStyle.alert)
//        
//        let alertActionTitle = NSLocalizedString("alert.error.actions.OK", comment: "OK on error alert")
//        
//        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
//        
//        alert.addAction(alertAction)
//        
//        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Convenience
    
    func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }
    
    
    
    
    //observer for av play
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~ OBSERVING " + keyPath!)
        // Only handle observations for the playerItemContext
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            
            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            
            // Switch over the status
            switch status {
            case .readyToPlay:
                print("Player Ready")
                self.playerIsReady = true
                self.calculateClipLength()
                
                if(self.startPlayingVideo) {
                    self.playerView.player?.play()
                    self.startPlayingVideo = false
                }
                
                break
            // Player item is ready to play.
            case .failed:
                print("Player Failed")
                self.playerIsReady = false
                break
                
            // Player item failed. See error.
            case .unknown:
                print("Player Unkown");
                self.playerIsReady = false
                
                break
                // Player item is not yet ready.
            }
        }
        
        
        
        if keyPath == #keyPath(AVPlayerItem.duration) {
            // Update timeSlider and enable/disable controls when duration > 0.0
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newDuration: CMTime
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            }
            else {
                newDuration = kCMTimeZero
            }
            
            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
//            let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
//            let currentTime = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0
//            
            //            timeSlider.maximumValue = Float(newDurationSeconds)
            //
            //            timeSlider.value = currentTime
            //
            //            rewindButton.isEnabled = hasValidDuration
            //
            //            playPauseButton.isEnabled = hasValidDuration
            //
            //            fastForwardButton.isEnabled = hasValidDuration
            //
            //            timeSlider.isEnabled = hasValidDuration
            
            //startTimeLabel.isEnabled = hasValidDuration
            //startTimeLabel.text = createTimeString(time: currentTime)
            
            //durationLabel.isEnabled = hasValidDuration
            //durationLabel.text = createTimeString(time: Float(newDurationSeconds))
        }
        else if keyPath == #keyPath(AVPlayer.rate) {
            // Update `playPauseButton` image.
            print("Hey rate is changing!");
            
            
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            
            print("Rate is now...\(newRate)")
            
            
            
            //            let buttonImageName = newRate == 1.0 ? "PauseButton" : "PlayButton"
            //
            //            let buttonImage = UIImage(named: buttonImageName)
            
            //            playPauseButton.setImage(buttonImage, for: UIControlState())
        }
        else if keyPath == #keyPath(AVPlayerItem.status) {
            // Display an error if status becomes `.Failed`.
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                handleErrorWithMessage(self.playerView.player?.currentItem?.error?.localizedDescription, error:player.currentItem?.error)
            }
        }
        
        
        
        
    }
    
    
    
//    // Update our UI when player or `player.currentItem` changes.
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//        // Make sure the this KVO callback was intended for this view controller.
//        guard context == &playerViewControllerKVOContext else {
//            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
//            return
//        }
//        
//    }
//    
    // Trigger KVO for anyone observing our properties affected by player and player.currentItem
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let affectedKeyPathsMappingByKey: [String: Set<String>] = [
            "duration":     [#keyPath(AVPlayerItem.duration)],
            "rate":         [#keyPath(AVPlayer.rate)]
        ]
        
        return affectedKeyPathsMappingByKey[key] ?? super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
}



//- (void)addPeriodicTimeObserver {
//    // Invoke callback every half second
//    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
//    // Queue on which to invoke the callback
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    // Add time observer
//    self.timeObserverToken =
//        [self.player addPeriodicTimeObserverForInterval:interval
//            queue:mainQueue
//            usingBlock:^(CMTime time) {
//            // Use weak reference to self
//            // Update player transport UI
//            }];
//}

