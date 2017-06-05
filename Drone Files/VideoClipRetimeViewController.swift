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
    
    var preserveDate = true
    
    
    @IBOutlet var videoSizeSelectMenu: NSPopUpButton!
    @IBOutlet var videoFrameRateSelectMenu: NSPopUpButton!
    @IBOutlet var outputFolderLabel: NSTextField!
    @IBOutlet var outputFileName: NSTextField!
    @IBOutlet var clipSpeedTextLabel: NSTextField!
    @IBOutlet var clipSpeedSlider: NSSlider!
    
    var clipSpeed = 100.00
    var burstMode = false
    @IBOutlet var burstModeButton: NSButton!

    
    var outputUrl: URL!
    var notificationCenter: NSUserNotificationCenter!
    
    var exportSession: AVAssetExportSession!

    
    @IBOutlet weak var playerView: AVPlayerView!
    
    var videoClips = [AVAsset]()
    var videos = [NSImage]()
    var imageTimings = [Float]()
    var imageLayer: CALayer!
    var syncLayer: AVSynchronizedLayer!
    var composition: AVMutableComposition!
    var videoComposition: AVMutableVideoComposition!
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
    
    var firstFile: URL!
    
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
        
        self.videoSizeSelectMenu.addItems(withTitles: self.appSettings.videoSizeSelectMenuOptions)
        
        self.videoSizeSelectMenu.selectItem(at: 7)
        
        self.videoFrameRateSelectMenu.addItems(withTitles: self.appSettings.videoFrameRateSelectMenuOptions)
        
        self.videoFrameRateSelectMenu.selectItem(at: 6)

        self.outputFolderLabel.stringValue = self.appSettings.videoClipsFolder.replacingOccurrences(of: self.appSettings.projectFolder, with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: "/Volumes", with: "")
        
        if(self.burstMode) {
            self.burstModeButton.state = 1
        } else {
            self.burstModeButton.state = 0
        }
        
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
        var i = 0
        self.receivedFiles.forEach({m in
            let urlPath = m as! String
            let url = URL(string: urlPath)
            var avAsset: AVAsset!
            if(self.appDelegate.isMov(file: url!)){
                
                let assetOptions = [AVURLAssetPreferPreciseDurationAndTimingKey : 1]
                avAsset = AVURLAsset(url: url!, options: assetOptions)
                self.videoClips.append(avAsset!)
                self.videoURLs.append(urlPath)
                
                if(i == 0) {
                    self.firstFile = url
                }
                i += 1
            }
        })
    }
    
    @IBAction func clipSpeedSliderChanged(sender: AnyObject) {
        self.clipSpeed = sender.doubleValue
        // self.clipSpeedTextLabel.doubleValue = sender.doubleValue
        self.generateComposition(self)
    }
    
    @IBAction func clipSpeedTextValueChanged(sender: AnyObject) {
        self.clipSpeed = sender.doubleValue
       // self.clipSpeedSlider.doubleValue = sender.doubleValue
        //self.generateComposition(self)
    }
    
    
    @IBAction func burstModeButtonChanged(sender: AnyObject) {
        
        if(sender.value == 0) {
            self.burstMode = false
        } else {
            self.burstMode = true
        }
        
        self.generateComposition(self)
        
        // self.clipSpeedSlider.doubleValue = sender.doubleValue
        //self.generateComposition(self)
    }
    
    
    func scaleDuration() {
        
        var speed = (self.clipSpeedSlider.doubleValue)
        
       // print("Clip Speed is... \(speed)")
        
        var newDuration: CMTime!
        
        if(speed != 0.5) {
        
            var seconds = self.composition.duration.seconds
            
            if(speed > 0.5) {
                //speed = speed
                speed = (speed - 0.5) * 100
                seconds = seconds * speed
            } else {
                speed = (0.5 - speed) * 100
                seconds = seconds / speed
            }
            
            self.clipSpeedTextLabel.doubleValue = speed
            
            // speed = abs(speed)
            // print("SPEEEEEED \(speed)")
            newDuration = CMTime.init(seconds: seconds, preferredTimescale: CMTimeScale(self.appSettings.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]))
        } else {
            newDuration = self.composition.duration
        }
        
        if(newDuration.seconds < 2.0) {
            newDuration = CMTime(seconds: 2.0, preferredTimescale: CMTimeScale(self.appSettings.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]))
        }
        
        self.composition.scaleTimeRange(CMTimeRangeMake(kCMTimeZero, self.composition.duration), toDuration: newDuration)
        
        
        self.setupPlayer()
        self.updateDurationLabel()
    }
     
     
    @IBAction func generateComposition(_ sender: AnyObject) {
        
        if(self.burstMode == true) {
            self.generateBurstComposition(self)
            return
        }
        
        let count = String(format: "%1d", self.receivedFiles.count)
        self.numberofFilesLabel.title = count

        var fullDuration = kCMTimeZero
        
        self.prepareAssets()
        self.outputUrl = self.generateVideoClipURL()
        
        var frame = 1
        var nextTime = kCMTimeZero
        self.composition = AVMutableComposition()
        
        let videoTrack = self.composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)

        // let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

        if(self.videoClips.count > 0) {
            let clip = self.videoClips[0]
            let assetTrack = clip.tracks(withMediaType: AVMediaTypeVideo)[0]
            let size = assetTrack.naturalSize
            
            if(self.appSettings.videoSizes.index(of: size)! > -1) {
                self.videoFrameRateSelectMenu.selectItem(at: self.appSettings.videoSizes.index(of: size)!)
            }
            
        }
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

        let framerate = self.appSettings.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]
        let size = self.appSettings.videoSizes[self.videoSizeSelectMenu.indexOfSelectedItem]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, Int32(framerate))
        videoComposition.renderSize = size
        
        
        self.scaleDuration()
        
        self.totalDuration = nextTime.seconds
    }
    
    
    
    
    
    
    @IBAction func generateBurstComposition(_ sender: AnyObject) {
        let count = String(format: "%1d", self.receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        var fullDuration = kCMTimeZero
        
        self.prepareAssets()
        self.outputUrl = self.generateVideoClipURL()
        
        var frame = 1
        var nextTime = kCMTimeZero
        self.composition = AVMutableComposition()
        
        let videoTrack = self.composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        self.videoClips.forEach({clipIndex in
       
            let assetTracks = clipIndex.tracks(withMediaType: AVMediaTypeVideo)
            
            // Process video
            if(assetTracks.count > 0) {
            
                
                print(assetTracks[0].nominalFrameRate)
                
                let frameRate = assetTracks[0].nominalFrameRate
                
                let interval = CMTime(seconds: 1.0,preferredTimescale: CMTimeScale(frameRate))
                
                let assetTrack = assetTracks[0] as AVAssetTrack
                
                let duration = clipIndex.duration
                
                fullDuration = CMTimeAdd(fullDuration, duration)
                var nextFrame = kCMTimeZero
                var clipPosition = kCMTimeZero
                
                var frames = 1.0
                while(clipPosition < duration) {
                    // let segment = CMTime(seconds: 0.2, preferredTimescale: 30)
                    
                    let oneFrame = CMTime(seconds: Double(1.0 / frameRate), preferredTimescale: duration.timescale)
                    print("Clip Frame Rate: \(frameRate)")

                    print("Duration Timescale: \(duration.timescale)")
                    print("Duration SECONDS: \(duration.seconds)")

                    print("One Frame...")
                    CMTimeShow(oneFrame)
                    
                    let assetRange = CMTimeRangeMake(nextFrame, oneFrame)
                    
                    nextFrame = CMTimeAdd(nextFrame, interval)
                    
                    clipPosition = CMTimeAdd(CMTime(seconds: (frames * interval.seconds), preferredTimescale: CMTimeScale(frameRate)), nextFrame)
                    
                    print("Clip position:")
                    CMTimeShow(clipPosition)
                    

                    do {
                        try videoTrack.insertTimeRange(assetRange, of: assetTrack, at: nextTime)
                    } catch {
                        let nserror = error as NSError
                        print("FUCK error...\(nserror)")
                    }
                    frames += 1
                    
                    nextTime = CMTimeAdd(nextTime, oneFrame)
                }
                
                
                frame += 1
            }
        })
        
        self.scaleDuration()
        
        self.totalDuration = nextTime.seconds
    }
    
    
    @IBAction func doSaveComposition(_ sender: AnyObject) {
       
        let clipFolder = URL(string: self.appDelegate.appSettings.videoClipsFolder)
        do {
            try FileManager.default.createDirectory(atPath: (clipFolder?.path)! , withIntermediateDirectories: true, attributes: nil)
            
            
        } catch _ as NSError {
            print("Error while creating a folder.")
        }
    
        
        // let es = self.exportSession
        
        let workerItem: MediaQueueWorkerItem!
        workerItem = MediaQueueWorkerItem()
        
        let timeLapseWorkerItem = DispatchWorkItem {
            workerItem.inProgress = true
            workerItem.outputUrl = self.outputUrl!
            workerItem.title = "Retime In Progress!"
            workerItem.originalFileDateUrl = self.firstFile
            
            let builder = RetimeBuilder(asset: self.composition.copy() as! AVAsset, url: self.outputUrl!)
            let framerate = self.appSettings.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]
            let size = self.appSettings.videoSizes[self.videoSizeSelectMenu.indexOfSelectedItem]
            
            builder.build(frameRate: Int32(framerate), outputSize: size, { progress in
                workerItem.inProgress = true
                workerItem.percent = (progress.fractionCompleted * 100.0)
            }, success: { url in
                workerItem.outputUrl = url
                
                workerItem.workerStatus = true
                workerItem.inProgress = false
                DispatchQueue.main.async {
                    self.finishSave(false, url: url, workerItem: workerItem)
                }
            }, failure: { error in
                print("ERROR \(error)")
                workerItem.workerStatus = false
                workerItem.inProgress = false
                workerItem.failed = true
                DispatchQueue.main.async {
                    self.finishSave(true, url: self.outputUrl!, workerItem: workerItem)

                }
            })
        }
        
        
        // timeLapseWorkerItem.perform()
        
        let queue = DispatchQueue.global(qos: self.appSettings.dispatchQueue)
        self.appDelegate.mediaQueue.queue.append(workerItem)
        queue.async(execute: timeLapseWorkerItem)
        
        timeLapseWorkerItem.notify(queue: DispatchQueue.main) {
            // print("percent = ", percent)
            print("Video Clip Export Worker launched... ")
        }
        
    }
    
    func setupAnimation() -> Bool {
        return true
    }
    
    
    func setupPlayer() {
        if(self.playerView?.player == nil) {

            let pi = AVPlayerItem(asset: self.composition.copy() as! AVAsset)
            // pi.videoComposition = self.videoComposition.copy() as! AVMutableVideoComposition
            
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
    
    func finishSave(_ err: Bool, url: URL, workerItem: MediaQueueWorkerItem) {
        
        DispatchQueue.main.async {
            self.saveTimeLapseButton.isEnabled = true
            if(!err) {
                
                self.setFileDate(originalFile: workerItem.originalFileDateUrl!, newFile: url)
                
                self.appDelegate.appSettings.mediaBinUrls.append(url)
                
                let notification = NSUserNotification()
                
                notification.identifier = "retime\(UUID().uuidString)"
                notification.title = "Retime Video Saved!"
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
        
        self.retimedVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Clip " + increment + " - Retimed.mov"
        
        let videoClipFullPath = self.appDelegate.appSettings.videoClipsFolder + "/" + self.retimedVideoName.replacingOccurrences(of: " " , with: "%20")
        
        let path = URL(string: videoClipFullPath)?.path
        
        if FileManager.default.fileExists(atPath: path!) {
            // print("Fuck that file exists..")
            
            let incrementer = "00000"
            
            self.retimedVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Clip " + increment + " - " + incrementer + " - Retimed.mov"
            
            
        }
        
        let videoClipURL = self.appDelegate.appSettings.videoClipsFolder + "/" + self.retimedVideoName
        
        
        // print("So far I came up with: \(videoClipURL)")
        let url = URL(string: videoClipURL.replacingOccurrences(of: " ", with: "%20"))
        
        self.outputFileName.stringValue = (url?.lastPathComponent)!
        
        return url!
        
    }
    
    
    
    
    func setFileDate(originalFile: URL, newFile: URL) {
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: originalFile.path)
            let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            
                        let attributes = [
                FileAttributeKey.creationDate: modificationDate,
                FileAttributeKey.modificationDate: modificationDate
            ]
            
            do {
                try FileManager.default.setAttributes(attributes, ofItemAtPath: newFile.path)
            } catch {
                print(error)
            }
        } catch let error {
            print("Error getting file modification attribute date: \(error.localizedDescription)")
        }
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
        
        if(durationSeconds > 0) {
            
            let (h,m,s,_) = self.secondsToHoursMinutesSeconds(seconds: Int((durationSeconds)))
            
            DispatchQueue.main.async {
                self.durationLabel?.stringValue = String(format: "%02d", h) + ":" + String(format: "%02d", m) + ":" + String(format: "%02d", s)
                
                // self.currentFrameLabel?.stringValue = String(format: "%02f", durationSeconds)
            }
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
