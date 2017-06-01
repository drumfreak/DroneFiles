//
//  TimeLapseViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/27/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit
import AppKit
import Quartz


class VideoClipRetimeViewController: NSViewController, NSUserNotificationCenterDelegate  {
    
    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var saveTimeLapseButton: NSButton!
    @IBOutlet var durationLabel: NSTextField!
    //@IBOutlet var progressIndicator: NSProgressIndicator!
    
    @IBOutlet var videoSizeSelectMenu: NSPopUpButton!
    @IBOutlet var videoFrameRateSelectMenu: NSPopUpButton!
    @IBOutlet var outputFolderLabel: NSTextField!
    @IBOutlet var outputFileName: NSTextField!
    @IBOutlet var clipSpeed: NSTextField!
    
    var outputUrl: URL!
    var notificationCenter: NSUserNotificationCenter!
    
    var exportSession: AVAssetExportSession!

    var videoSizeSelectMenuOptions = [
        "[16:9] - 1024×576",
        "[16:9] - 1152×648",
        "[16:9] - 1280 x 720 (720HD)",
        "[16:9] - 1366×768",
        "[16:9] - 1600×900",
        "[16:9] - 1920 x 1080 (1080HD)",
        "[16:9] - 2560 x 1440 (1440HD)",
        "[16:9] - 3840 x 2160 (4k)",
        "[16:9] - 7680 x 4320 (8k)",
        
        "[4:3] - 640×480",
        "[4:3] - 800×600",
        "[4:3] - 960×720",
        "[4:3] - 1024×768",
        "[4:3] - 1280×960",
        "[4:3] - 1400×1050",
        "[4:3] - 1440×1080",
        "[4:3] - 1600×1200",
        "[4:3] - 1856×1392",
        "[4:3] - 1920×1440",
        "[4:3] - 2048×1536",
        
        "[16:10] - 1280×800",
        "[16:10] - 1440×900",
        "[16:10] - 1680×1050",
        "[16:10] - 1920×1200",
        "[16:10] - 2560×1600"
    ]
    
    
    var videoSizes: [NSSize] = [NSSize(width: 1152, height: 648),
                                NSSize(width: 1280, height: 720),
                                NSSize(width: 1366, height: 768),
                                NSSize(width: 1600, height: 900),
                                NSSize(width: 1920, height: 1080),
                                NSSize(width: 2560, height: 1440),
                                NSSize(width: 3840, height: 2160),
                                NSSize(width: 7680, height: 4320),
                                NSSize(width: 640, height: 480),
                                NSSize(width: 800, height: 600),
                                NSSize(width: 960, height: 720),
                                NSSize(width: 1024, height: 768),
                                NSSize(width: 1280, height: 960),
                                NSSize(width: 1400, height: 1050),
                                NSSize(width: 1440, height: 1080),
                                NSSize(width: 1600, height: 1200),
                                NSSize(width: 1856, height: 1392),
                                NSSize(width: 1920, height: 1440),
                                NSSize(width: 2048, height: 1536),
                                NSSize(width: 1280, height: 800),
                                NSSize(width: 1440, height: 900),
                                NSSize(width: 1680, height: 1050),
                                NSSize(width: 1920, height: 1200),
                                NSSize(width: 2560, height: 1600)
    ]
    
    
    var videoFrameRateSelectMenuOptions = ["1", "5", "10", "15", "20", "24", "29.97", "30", "60", "120"]
    
    var frameRates = [1, 2, 5, 10, 15, 20, 24, 30, 60, 120, 240, 320, 420]
    
    
    @IBOutlet weak var playerView: AVPlayerView!
    
    var videoClips = [AVAsset]()
    var videos = [NSImage]()
    var imageTimings = [Float]()
    var imageLayer: CALayer!
    var syncLayer: AVSynchronizedLayer!
    var composition: AVMutableComposition!
    var mutableVideoComposition: AVMutableVideoComposition!
    var avPlayerLayer: AVPlayerLayer!
    var playerViewControllerKVOContext = 0
    var totalDuration = 0.0
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerIsReady = false
    
    var retimedVideoName = ""
    var frameInterval = Float64(0.2)
    
    var videoURLs = [String]()
    
    var viewIsLoaded = false
    
    var receivedFiles = NSMutableArray() {
        didSet {
            if(self.viewIsLoaded) {
                let count = String(format: "%", receivedFiles.count)
                self.numberofFilesLabel.title = count
                // self.cleanupPlayer()
                // self.generateTimeLapse(self)
                
                
                if(self.receivedFiles.count > 0) {
                    self.saveTimeLapseButton.isEnabled = true
                } else {
                    self.saveTimeLapseButton.isEnabled = false
                }
                
                self.generateComposition(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        self.notificationCenter = NSUserNotificationCenter.default
        self.notificationCenter.delegate = self

        
        //DispatchQueue.main.async {
        //self.progressIndicator.isHidden = true
        if(self.receivedFiles.count > 0) {
            self.saveTimeLapseButton.isHidden = false
        }
        //}
        
        self.videoSizeSelectMenu.addItems(withTitles: self.videoSizeSelectMenuOptions)
        
        self.videoSizeSelectMenu.selectItem(at: 5)
        
        self.videoFrameRateSelectMenu.addItems(withTitles: self.videoFrameRateSelectMenuOptions)
        
        self.videoFrameRateSelectMenu.selectItem(at: 3)

        self.outputFolderLabel.stringValue = self.appSettings.videoClipsFolder.replacingOccurrences(of: self.appSettings.projectFolder, with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: "/Volumes", with: "")
        
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        // self.generateTimeLapse(self)
        
        // self.prepareAssets()
        
        self.generateComposition(self)
        
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.viewIsLoaded = false
        // self.deallocObservers()
    }
    
    
    
//    func prepareVideoURLs() {
//        // var currentTime = CMTimeMakeWithSeconds(0, 30)
//        self.videoURLs.removeAll()
//        
//        self.receivedFiles.forEach({m in
//            let urlPath = m as! String
//            let url = URL(string: urlPath)
//            if(self.appDelegate.isMov(file: url!)) {
//                self.videoURLs.append(urlPath)
//            }
//        })
//    }
    
    func deallocObservers() {
        if(self.playerIsReady) {
            self.playerIsReady = false
            print("Deallocating Observers from playerItem")
            self.player.pause()

            self.player.currentItem!.removeObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: &playerViewControllerKVOContext)

            // self.player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: &playerViewControllerKVOContext)

            self.playerView.player = nil
            self.playerItem = nil
            self.player = nil
            self.imageLayer = nil
            self.syncLayer = nil
        }
     }
     
    func cleanupPlayer() {
        if(self.player.currentItem != nil) {
            self.deallocObservers()
        }
    }
    
    func prepareAssets() {
        // var currentTime = CMTimeMakeWithSeconds(0, 30)
        self.videoURLs.removeAll()
        self.imageTimings.removeAll()
        self.videoClips.removeAll()
        self.receivedFiles.forEach({m in
            let urlPath = m as! String
            let url = URL(string: urlPath)
            var avAsset: AVAsset!
            if(self.appDelegate.isMov(file: url!)){
                let assetOptions = [AVURLAssetPreferPreciseDurationAndTimingKey : 1]
                avAsset = AVURLAsset(url: url!, options: assetOptions)
                self.videoClips.append(avAsset!)
                self.videoURLs.append(urlPath)
            }
        })
    }
    
     
     
    @IBAction func generateComposition(_ sender: AnyObject) {
        let count = String(format: "%1d", self.receivedFiles.count)
        self.numberofFilesLabel.title = count

        var fullDuration = kCMTimeZero
        
        self.prepareAssets()
        self.outputUrl = self.generateVideoClipURL()
        
        
        var frame = 1
        var nextTime = kCMTimeZero
        self.composition = AVMutableComposition()
        // self.mutableVideoComposition = AVMutableVideoComposition()

        let videoTrack = self.composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)

        // let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

        self.videoClips.forEach({clipIndex in

            // Check for video.
            let assetTracks = clipIndex.tracks(withMediaType: AVMediaTypeVideo)
            
            
            // Process video
            if(assetTracks.count > 0) {
                
                let assetTrack = assetTracks[0] as AVAssetTrack
                let duration = clipIndex.duration
                fullDuration = CMTimeAdd(fullDuration, duration)
                
                // Loop through and make a fuckload of entries.

                let assetRange = CMTimeRangeMake(kCMTimeZero, duration)
                
                
                // We know how long it is...
                
                // Now get our fps / interval
                
                // loop through and add the frames as timeranges.
                
                // let currentTime = kCMTimeZero
                
                do {
                    try videoTrack.insertTimeRange(assetRange, of: assetTrack, at: nextTime)
                } catch {
                    let nserror = error as NSError
                    print("FUCK error...\(nserror)")

                    // NSApplication.shared().presentError(nserror)
                }
                

                nextTime = CMTimeAdd(nextTime, duration)

                frame += 1
            }
        })

        //        let instruction = AVMutableVideoCompositionInstruction()
        //        let videoComposition = AVMutableVideoComposition()
        //        
        //        instruction.layerInstructions.append(layerInstruction)
        //        
        //        videoComposition.instructions = [instruction]
        //        
        //        videoComposition.frameDuration = CMTimeMake(1,30);

        
        // print("Lets see... frame duration for 240 is \(CMTimeMake(1, 30))")
       // print("In seconds that is... \(videoComposition.frameDuration.seconds)")

        
        
        
        
        self.composition.scaleTimeRange(CMTimeRangeMake(kCMTimeZero, fullDuration), toDuration: CMTime(seconds: 10, preferredTimescale: 1))
            
        
        self.totalDuration = nextTime.seconds
        //                self.composition.tracks.forEach({ m in
        //                    print("Composition Track: \(m)")
        //                    m.segments.forEach({ z in
        //                        print("Segments: \(z)")
        //                    })
        //                })

        if(self.setupAnimation()){
            self.setupPlayer()
        }
        
        // videoComposition.renderSize = NSSize(width: 1920, height: 1080)

        //self.clipFileSizeVar = self.exportSession.estimatedOutputFileLength
    }
    
    
    
    
    @IBAction func doSaveComposition(_ sender: AnyObject) {
       
        let clipFolder = URL(string: self.appDelegate.appSettings.videoClipsFolder)
        do {
            try FileManager.default.createDirectory(atPath: (clipFolder?.path)! , withIntermediateDirectories: true, attributes: nil)
            
            
        } catch _ as NSError {
            print("Error while creating a folder.")
        }
        
        
        func saveClippedFileCompleted(url: URL!) {
            self.finishSave(false, url: url)
            
            print("Completed...")
            
        }
        
        func saveClippedFileFailed() {
            print("Session FAILED")
            DispatchQueue.main.async {
               // self.saveTrimmedVideoButton.isEnabled = true
            }
        }
        
        func saveClippedFileUnknown() {
            print("I don't know..");
        }
        
        // let es = self.exportSession
        
        let workerItem: MediaQueueWorkerItem!
        
        workerItem = MediaQueueWorkerItem()
        
        let timeLapseWorkerItem = DispatchWorkItem {
            
            workerItem.inProgress = true
            workerItem.outputUrl = self.outputUrl!
            workerItem.title = "Retime In Progress!"
            
            let builder = RetimeBuilder(asset: self.composition.copy() as! AVAsset, url: self.outputUrl!)
            
            // print("New Timelapse video file..." + (URL(string: timeLapseUrl)?.lastPathComponent)!)
            
            
            let framerate = self.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]
            
            let size = self.videoSizes[self.videoSizeSelectMenu.indexOfSelectedItem]
            
            // var errCount = 0
            
            builder.build(frameRate: Int32(framerate), outputSize: size, { progress in
                // print(progress.fractionCompleted)
                workerItem.inProgress = true
                // print("fraction completed...\(progress.fractionCompleted * 100.0)")
                
                workerItem.percent = (progress.fractionCompleted * 100.0)
            }, success: { url in
                // print(url)
                workerItem.outputUrl = url
                // self.finishSave(false, url: url)
                workerItem.workerStatus = true
                workerItem.inProgress = false
                DispatchQueue.main.async {
                    self.finishSave(false, url: url)
                }
                
            }, failure: { error in
                print("ERROR \(error)")
                // errCount += 1
                
                //if(errCount > 1) {
                    DispatchQueue.main.async {
                        self.finishSave(true, url: self.outputUrl!)
                    }
                //}
                
            })
        }
        
        
        // timeLapseWorkerItem.perform()
        
        let queue = DispatchQueue.global(qos: .utility)
        self.appDelegate.mediaQueue.queue.append(workerItem)
        queue.async(execute: timeLapseWorkerItem)
        
        timeLapseWorkerItem.notify(queue: DispatchQueue.main) {
        
            // print("percent = ", percent)
            print("Worker launched... ")
        }
        
    }
    
    func setupAnimation() -> Bool {
        return true
    }
    
    
    func setupPlayer() {
        if(self.playerView?.player == nil) {

            let pi = AVPlayerItem(asset: self.composition.copy() as! AVAsset)

            let avPlayer = AVPlayer(playerItem: pi)

            self.player = avPlayer
            self.playerView.player?.volume = 0.0
            self.playerView.player = self.player

            // self.player?.currentItem!.addObserver(self, forKeyPath: #keyPath(player.currentItem.status), options:   [.new, .initial], context: &playerViewControllerKVOContext)

            self.playerIsReady = true

        } else {
            
            // self.player?.currentItem!.removeObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: &playerViewControllerKVOContext)
            
            let pi = AVPlayerItem(asset: self.composition.copy() as! AVAsset)

            self.player?.replaceCurrentItem(with: pi)
        }
        
        self.updateDurationLabel()
        
    }

    //observer for av play

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }


        if keyPath == #keyPath(player.currentItem.status) {
            let status: AVPlayerItemStatus

            // Get the status change from the change dictionary
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
        }

        print("Keypath: \(String(describing: status))")

        // Switch over the status
        switch status {
            case .readyToPlay:
                // Player item is ready to play.
                print("Player Ready")
                print("Composition Duration.... \(self.player.currentItem!.duration.seconds)")
                self.playerIsReady = true
                self.player.play()

            break
            case .failed:
                // Player item failed. See error.

                print("Player Failed")
                self.playerIsReady = false
            break

            case .unknown:
                print("Player Unkown")
                self.playerIsReady = false

            break
            // Player item is not yet ready.
            }
        }

        if keyPath == #keyPath(AVPlayerItem.duration) {

        } else if keyPath == #keyPath(AVPlayer.rate) {


        }

    }
    
    func finishSave(_ err: Bool, url: URL) {
        DispatchQueue.main.async {
            self.saveTimeLapseButton.isEnabled = true
//            self.progressIndicator.isHidden = true
//            self.progressIndicator.doubleValue = 0.00
//            self.progressLabel.stringValue = "0.0%"
//            self.progressLabel.isHidden = true
            if(!err) {
                self.appDelegate.appSettings.mediaBinUrls.append(url)
                
                let notification = NSUserNotification()
                
//                if(self.videoURLs.count > 0) {
//                    notification.contentImage = NSImage(contentsOf: URL(string: self.videoURLs[0])!)
//                }
                
                notification.identifier = "retime\(UUID().uuidString)"
                notification.title = "Retime Video Saved!"
                notification.informativeText = url.lastPathComponent.replacingOccurrences(of: "%20", with: " ")
                
                notification.soundName = NSUserNotificationDefaultSoundName
                notification.notificationUrl = url.absoluteString
                notification.hasActionButton = true
                notification.actionButtonTitle = "View"
                // notification.otherButtonTitle = "Dismiss"
                
                notification.setValue(true, forKey: "_showsButtons")
                
                var actions = [NSUserNotificationAction]()
                
                let action1 = NSUserNotificationAction(identifier: "viewNow", title: url.absoluteString)
                
                let action2 = NSUserNotificationAction(identifier: "openInFinder", title: "Open in Quicktime")
                
                //let action3 = NSUserNotificationAction(identifier: "eatMe", title: "Something else")
                
                actions.append(action1)
                actions.append(action2)
                //actions.append(action3)
                
                notification.additionalActions = actions
                
                self.notificationCenter.deliver(notification)
                
            } else {
                
                let myPopup: NSAlert = NSAlert()
                
                myPopup.messageText = "Retime Failed"
                myPopup.informativeText = "Something went wrong. Dispatching Monkeys to find out why."
                myPopup.alertStyle = NSAlertStyle.warning
                myPopup.addButton(withTitle: "OK")
                myPopup.runModal()
                
            }
        }
    }

    // Video Naming
    func getClippedVideosIncrement(folder: String) -> String {
        var incrementer = "00"
        var isDirectory: ObjCBool = false
        let foo = URL(string:folder)
        
        if FileManager.default.fileExists(atPath: (foo?.path)!, isDirectory: &isDirectory) {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: foo!, includingPropertiesForKeys: nil, options: [])
                if(files.count > 0) {
                    incrementer = String(format: "%02d", files.count)
                }
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func generateVideoClipURL() -> URL {
        
        let increment = getClippedVideosIncrement(folder: self.appDelegate.appSettings.videoClipsFolder)
        
        self.retimedVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Retimed " + increment + ".mov"
        
        let videoClipFullPath = self.appDelegate.appSettings.videoClipsFolder + "/" + self.retimedVideoName.replacingOccurrences(of: " " , with: "%20")
        
        let path = URL(string: videoClipFullPath)?.path
        
        
        if FileManager.default.fileExists(atPath: path!) {
            // print("Fuck that file exists..")
            
            let incrementer = "00000"
            
            self.retimedVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Retimed " + increment + " - " + incrementer + ".mov"
            
            
        }
        
        let videoClipURL = self.appDelegate.appSettings.videoClipsFolder + "/" + self.retimedVideoName
        
        
        // print("So far I came up with: \(videoClipURL)")
        return URL(string: videoClipURL.replacingOccurrences(of: " ", with: "%20"))!
        
    }
    
    
//    func updateTimerLabel() {
//        let cur = self.appDelegate.videoPlayerViewController?.playerView.player?.currentTime()
//        
//        let durationSeconds = CMTimeGetSeconds((cur)!)
//        
//        let (h,m,s,_) = self.secondsToHoursMinutesSeconds(seconds: Int((durationSeconds)))
//        
//        DispatchQueue.main.async {
//            
//            self.durationLabel?.stringValue = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
//            
//            // self.currentFrameLabel?.stringValue = String(format: "%02f", durationSeconds)
//        }
//    }
//    
    
    func updateDurationLabel() {
        let cur = self.player?.currentItem?.duration
        
        let durationSeconds = CMTimeGetSeconds((cur)!)
        
        let (h,m,s,_) = self.secondsToHoursMinutesSeconds(seconds: Int((durationSeconds)))
        
        DispatchQueue.main.async {
            self.durationLabel?.stringValue = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
            
            // self.currentFrameLabel?.stringValue = String(format: "%02f", durationSeconds)
        }
    }

    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60, (seconds % 36000) % 60)
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
            self.appDelegate.fileBrowserViewController.sourceFolderOpened = URL(string: self.appDelegate.appSettings.videoClipsFolder)
            
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: notification.notificationUrl!)
            
        case .contentsClicked:
            self.appDelegate.fileBrowserViewController.sourceFolderOpened = URL(string: self.appDelegate.appSettings.videoClipsFolder)
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: notification.notificationUrl!)
        default:
            break
        }
    }



}
