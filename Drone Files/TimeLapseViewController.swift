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


class TimeLapseViewController: NSViewController {

    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var confirmDeleteButton: NSButton!
    @IBOutlet var durationLabel: NSTextField!
    @IBOutlet weak var playerView: AVPlayerView!
    var composition: AVMutableComposition!
    var mutableVideoComposition: AVMutableVideoComposition!
    var avPlayerLayer: AVPlayerLayer!
    
    var playerViewControllerKVOContext = 2
    var totalDuration = 0.0
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var playerIsReady = false
    
    var frameInterval = Float64(0.2)
    
    var videoClips = [AVAsset]()
    var images = [NSImage]()
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
                self.generateTimeLapse(self)

            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            let count = String(format: "%1d", receivedFiles.count)
            self.numberofFilesLabel.title = count
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        // self.generateTimeLapse(self)

    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.viewIsLoaded = false
        // self.deallocObservers()
    }
    
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
            
            // print("FUCKING ASSET Tracks: \(clipIndex)")
            
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
    
}
