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


class VideoClipMergeViewController: NSViewController {
    
    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var saveTimeLapseButton: NSButton!
    @IBOutlet var durationLabel: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    @IBOutlet var videoSizeSelectMenu: NSPopUpButton!
    @IBOutlet var videoFrameRateSelectMenu: NSPopUpButton!
    @IBOutlet var outputFolderLabel: NSTextField!
    
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
    
    @IBOutlet weak var playerView: AVPlayerView!
    
    /*
     var videoClips = [AVAsset]()
     var images = [NSImage]()
     var imageTimings = [Float]()
     var imageLayer: CALayer!
     var syncLayer: AVSynchronizedLayer!
     var composition: AVMutableComposition!
     var mutableVideoComposition: AVMutableVideoComposition!
     var avPlayerLayer: AVPlayerLayer!
     var playerViewControllerKVOContext = 2
     var totalDuration = 0.0
     var player: AVPlayer!
     var playerItem: AVPlayerItem!
     var playerIsReady = false
     */
    
    
    var timelapseVideoName = ""
    
    var frameInterval = Float64(0.2)
    
    var imageUrls = [String]()
    
    var imageTimings = [Float]()
    var imageLayer: CALayer!
    var syncLayer: AVSynchronizedLayer!
    
    var viewIsLoaded = false
    
    var receivedFiles = NSMutableArray() {
        didSet {
            if(self.viewIsLoaded) {
                let count = String(format: "%", receivedFiles.count)
                self.numberofFilesLabel.title = count
                // self.cleanupPlayer()
                // self.generateTimeLapse(self)
                
                
                if(self.receivedFiles.count > 2) {
                    self.saveTimeLapseButton.isEnabled = true
                } else {
                    self.saveTimeLapseButton.isEnabled = false
                }
                
                self.prepareImageURLs()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        //DispatchQueue.main.async {
            self.progressIndicator.isHidden = true
            if(self.receivedFiles.count > 2) {
                self.saveTimeLapseButton.isHidden = false
            }
        //}
        
        self.videoSizeSelectMenu.addItems(withTitles: self.videoSizeSelectMenuOptions)
        
        self.videoSizeSelectMenu.selectItem(at: 5)
        
        self.videoFrameRateSelectMenu.addItems(withTitles: self.videoFrameRateSelectMenuOptions)
        
        self.videoFrameRateSelectMenu.selectItem(at: 3)
        
        
        
        
        self.outputFolderLabel.stringValue = self.appSettings.timeLapseFolder.replacingOccurrences(of: self.appSettings.projectFolder, with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: "/Volumes", with: "")
        
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        // self.generateTimeLapse(self)
        
        prepareImageURLs()
        
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.viewIsLoaded = false
        // self.deallocObservers()
    }
    
    
    
    func prepareImageURLs() {
        // var currentTime = CMTimeMakeWithSeconds(0, 30)
        self.imageUrls.removeAll()
        
        self.receivedFiles.forEach({m in
            let urlPath = m as! String
            let url = URL(string: urlPath)
            if(self.appDelegate.isImage(file: url!)) {
                self.imageUrls.append(urlPath)
            }
        })
    }
    
    func finishSave(_ err: Bool, url: URL) {
        DispatchQueue.main.async {
            self.saveTimeLapseButton.isEnabled = true
            self.progressIndicator.isHidden = true
            self.progressIndicator.doubleValue = 0.00
            
            if(!err) {
                self.appDelegate.appSettings.mediaBinUrls.append(url)
            }
        }
    }
    
//    @IBAction func writeTimeLapse(_ sender: AnyObject) {
//        
//        self.saveTimeLapseButton.isEnabled = false
//        
//        self.progressIndicator.isHidden = false
//        
//        self.progressIndicator.doubleValue = 0.00
//        
//        let timeLapseUrl = self.generateTimeLapseURL()
//        
//        let builder = TimeLapseBuilder(photoURLs: self.imageUrls, url: timeLapseUrl)
//        
//        print("New Timelapse video file..." + timeLapseUrl)
//        
//        builder.build(frameRate: Float, outputSize: CGSize(width: 1920, height: 1080), { progress in
//            print(progress)
//            DispatchQueue.main.async {
//                self.progressIndicator.doubleValue = progress.fractionCompleted
//            }
//        }, success: { url in
//            print(url)
//            self.finishSave(false, url: url)
//        }, failure: { error in
//            print(error)
//            self.finishSave(true, url: URL(string: timeLapseUrl)!)
//        })
//    }
//    
    // Video Clipping
    func getClippedVideosIncrement(folder: String) -> String {
        var incrementer = "00"
        var isDirectory: ObjCBool = false
        var foo = URL(string:folder)?.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        foo = foo?.replacingOccurrences(of: "%20", with: " ")
        
        
        if FileManager.default.fileExists(atPath: foo!, isDirectory: &isDirectory) {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.appDelegate.appSettings.timeLapseFolder)!, includingPropertiesForKeys: nil, options: [])
                if(files.count > 0) {
                    incrementer = String(format: "%02d", files.count)
                }
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func generateTimeLapseURL() -> String {
        
        let increment = getClippedVideosIncrement(folder: self.appDelegate.appSettings.timeLapseFolder)
        
        self.timelapseVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Timelapse " + increment + ".mov"
        
        let timelapseFullPath = self.appDelegate.appSettings.timeLapseFolder + "/" + self.timelapseVideoName
        
        if FileManager.default.fileExists(atPath: timelapseFullPath.replacingOccurrences(of: "file://", with: "")) {
            // print("Fuck that file exists..")
            
            let incrementer = "00000"
            
            self.timelapseVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Timelapse " + increment + " - " + incrementer + ".mov"
            
            
        } else {
            print("That file does not exist..")
        }
        
        let timeLapseUrl = self.appDelegate.appSettings.timeLapseFolder + "/" + self.timelapseVideoName
        
        
        print("So far I came up with: \(timeLapseUrl)")
        
        
        //        self.trimmedClipNewLabel.isHidden = false
        //        self.trimmedClipNewLabel.stringValue = self.clippedVideoName
        //        self.trimmedClipNewPathLabel.isHidden = false
        //        self.trimmedClipNewPathLabel.stringValue = self.clippedVideoPath
        //
        return timeLapseUrl.replacingOccurrences(of: " ", with: "%20")
    }
    
    
    
    
    
    /*
     
     SAVE THIS CODE FOR A BIT. Previews the animation with core animation.
     
     
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
     self.images.removeAll()
     self.imageTimings.removeAll()
     self.videoClips.removeAll()
     self.receivedFiles.forEach({m in
     let urlPath = m as! String
     let url = URL(string: urlPath)
     var avAsset: AVAsset!
     if(self.appDelegate.isImage(file: url!)) {
     let image = ImageFile(url: url!)
     avAsset = AVURLAsset(url: image.imgUrl!, options: nil)
     self.images.append(image.thumbnail!)
     self.videoClips.append(avAsset!)
     } else if(self.appDelegate.isMov(file: url!)){
     let assetOptions = [AVURLAssetPreferPreciseDurationAndTimingKey : 1]
     avAsset = AVURLAsset(url: url!, options: assetOptions)
     self.videoClips.append(avAsset!)
     }
     })
     }
     
     
     
     @IBAction func generateTimeLapse(_ sender: AnyObject) {
     let count = String(format: "%1d", self.receivedFiles.count)
     self.numberofFilesLabel.title = count
     
     self.prepareAssets()
     var frame = 1
     var nextTime = kCMTimeZero
     self.composition = AVMutableComposition()
     self.mutableVideoComposition = AVMutableVideoComposition()
     
     let videoTrack = self.composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
     
     self.videoClips.forEach({clipIndex in
     let foo = clipIndex.tracks(withMediaType: AVMediaTypeMuxed)
     
     
     foo.forEach({ z in
     // print("FOO TRACKS: \(z)")
     })
     
     
     // clipIndex.
     
     // Check for video.
     let assetTracks = clipIndex.tracks(withMediaType: AVMediaTypeVideo)
     
     assetTracks.forEach({ z in
     // print("Asset TRACKS: \(z)")
     })
     
     // Process video
     if(assetTracks.count > 0) {
     let assetTrack = assetTracks[0] as AVAssetTrack
     let duration = clipIndex.duration
     
     let assetRange = CMTimeRangeMake(kCMTimeZero, duration)
     
     do {
     try videoTrack.insertTimeRange(assetRange, of: assetTrack, at: nextTime)
     } catch {
     let nserror = error as NSError
     print("FUCK error...\(nserror)")
     
     // NSApplication.shared().presentError(nserror)
     }
     
     
     let firstTransform = assetTrack.preferredTransform
     
     
     // Check the first video track's preferred transform to determine if it was recorded in portrait mode.
     if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
     // isVideoPortrait = true
     }
     
     
     
     let instruction = AVMutableVideoCompositionInstruction()
     instruction.timeRange = assetRange
     
     let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: assetTrack)
     
     videoLayerInstruction.setTransform(firstTransform, at: nextTime)
     
     instruction.layerInstructions.append(videoLayerInstruction)
     self.mutableVideoComposition.instructions.append(instruction)
     
     nextTime = CMTimeAdd(nextTime, duration)
     
     frame += 1
     } else {
     
     // Must be an image.
     
     let duration = CMTimeMakeWithSeconds(self.frameInterval, 30)
     
     
     let assetDuration = CMTimeRangeMake(kCMTimeZero, duration)
     let assetRange = CMTimeRangeMake(nextTime, duration)
     
     let blank = Bundle.main.path(forResource: "blankClip", ofType: "mp4")
     
     // print("blank \(String(describing: blank))")
     
     let segment = AVCompositionTrackSegment(url: URL(fileURLWithPath: blank!), trackID: kCMPersistentTrackID_Invalid, sourceTimeRange: assetDuration, targetTimeRange: assetRange)
     
     self.imageTimings.append(Float(nextTime.seconds))
     
     videoTrack.segments.append(segment)
     
     nextTime = CMTimeAdd(nextTime, duration)
     
     frame += 1
     }
     })
     
     self.totalDuration = nextTime.seconds
     
     // print("Segements: \(videoTrack.segments)")
     
     self.mutableVideoComposition.renderSize =  CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
     
     let parentLayer = CALayer()
     let videoLayer = CALayer()
     
     parentLayer.frame = CGRect(x: 0, y: 0, width: self.mutableVideoComposition.renderSize.width, height: self.mutableVideoComposition.renderSize.height)
     
     videoLayer.frame = CGRect(x: 0, y: 0, width: self.mutableVideoComposition.renderSize.width, height: self.mutableVideoComposition.renderSize.height)
     
     parentLayer.addSublayer(videoLayer)
     
     let animationTool = AVVideoCompositionCoreAnimationTool(additionalLayer: videoLayer, asTrackID: kCMPersistentTrackID_Invalid)
     
     self.mutableVideoComposition.animationTool = animationTool
     
     // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
     self.mutableVideoComposition.frameDuration = CMTimeMake(1,30);
     
     //        self.composition.tracks.forEach({ m in
     //            print("Composition Track: \(m)")
     //            m.segments.forEach({ z in
     //                print("Segments: \(z)")
     //            })
     //        })
     
     if(self.setupAnimation()){
     self.setupPlayer()
     }
     }
     
     func setupAnimation() -> Bool {
     
     self.imageLayer?.removeAllAnimations()
     //        self.imageLayer?.removeFromSuperlayer()
     //        self.imageLayer = nil
     self.imageLayer = CALayer()
     
     self.imageLayer.frame = CGRect(x: 0, y: 20, width: (self.playerView.layer?.bounds.width)!, height: (self.playerView.layer?.bounds.height)! - 24)
     
     self.imageLayer.contentsGravity = kCAGravityResizeAspect
     
     // self.view.layer?.addSublayer(imageLayer)
     
     let anim = CAKeyframeAnimation(keyPath: "contents")
     // print("Player duration: \(playerItem.duration.seconds)")
     
     anim.duration = self.totalDuration
     // anim.repeatDuration = 20.0
     anim.beginTime = AVCoreAnimationBeginTimeAtZero
     anim.values = self.images
     anim.keyTimes = self.imageTimings as [NSNumber]
     anim.repeatCount = 0
     
     self.imageTimings.forEach({n in
     print("KEY TIMINGS: \(n)")
     })
     
     self.imageLayer.add(anim, forKey: "contents")
     
     return true
     }
     
     
     func setupPlayer() {
     
     let playerItem = AVPlayerItem(asset: self.composition.copy() as! AVAsset)
     
     if(self.playerView?.player == nil) {
     
     let avPlayer = AVPlayer(playerItem: playerItem)
     
     self.player = avPlayer
     self.playerView.player?.volume = 0.0
     self.playerView.player = self.player
     
     self.player.currentItem!.addObserver(self, forKeyPath: #keyPath(player.currentItem.status), options:   [.new, .initial], context: &playerViewControllerKVOContext)
     
     // self.player.currentItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.duration), options:   [.new, .initial], context: &playerViewControllerKVOContext)
     
     self.playerIsReady = true
     
     } else {
     self.playerView.player!.replaceCurrentItem(with: playerItem)
     // self.view.layer?.addSublayer(self.avPlayerLayer)
     }
     
     //        if(self.syncLayer != nil) {
     //            self.syncLayer!.removeFromSuperlayer()
     //            self.syncLayer = nil
     //        }
     
     self.syncLayer = AVSynchronizedLayer(playerItem: (self.playerView.player?.currentItem)!)
     
     self.syncLayer.addSublayer(self.imageLayer!)
     
     self.playerView?.layer!.addSublayer(self.syncLayer!)
     
     }
     
     //observer for av play
     
     override func observeValue(forKeyPath keyPath: String?,
     of object: Any?,
     change: [NSKeyValueChangeKey : Any]?,
     context: UnsafeMutableRawPointer?) {
     
     guard context == &playerViewControllerKVOContext else {
     super.observeValue(forKeyPath: keyPath,
     of: object,
     change: change,
     context: context)
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
     */
    
    
    //    func stringFromTimeInterval(interval: TimeInterval) -> String {
    //        let ti = NSInteger(interval)
    //        let ms = Int((interval % 1) * 1000)
    //        let seconds = ti % 60
    //        let minutes = (ti / 60) % 60
    //        let hours = (ti / 3600)
    //
    //        if hours > 0 {
    //            return NSString(format: "%0.2d:%0.2d:%0.2d.%0.2d", hours, minutes, seconds, ms) as String
    //        }else if minutes > 0 {
    //            return NSString(format: "%0.2d:%0.2d.%0.2d", minutes, seconds, ms) as String
    //        }else {
    //            return NSString(format: "%0.2d.%0.2d", seconds, ms) as String
    //        }
    //    }
}
