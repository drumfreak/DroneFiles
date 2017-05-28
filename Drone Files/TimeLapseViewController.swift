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
    // composition = AVMutableComposition()
    
    var playerViewControllerKVOContext = 2

    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var videoClips = [AVAsset]()
    var viewIsLoaded = false
    
    var receivedFiles = NSMutableArray() {
        didSet {
            if(self.viewIsLoaded) {
                let count = String(format: "%", receivedFiles.count)
                self.numberofFilesLabel.title = count
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
           }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        addObserver(self, forKeyPath: #keyPath(playerItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)

        
        self.generateTimeLapse(self)
        
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.viewIsLoaded = false
    }
    
    func prepareAssets() {
        self.videoClips.removeAll()
        self.receivedFiles.forEach({m in
            let urlPath = m as! String
            let url = URL(string: urlPath)
            let assetOptions = [AVURLAssetPreferPreciseDurationAndTimingKey : 1]
            let avAsset = AVURLAsset(url: url!, options: assetOptions)
            self.videoClips.append(avAsset)
        })
    }

    @IBAction func generateTimeLapse(_ sender: AnyObject) {
        
        self.prepareAssets()
        var frame = 1
        var nextTime = kCMTimeZero
        self.composition = AVMutableComposition()
        self.mutableVideoComposition = AVMutableVideoComposition()

        let videoTrack = self.composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let instruction = AVMutableVideoCompositionInstruction()
        
        self.videoClips.forEach({clipIndex in
            
            print("Asset Tracks: \(clipIndex.tracks)")

            let assetTracks = clipIndex.tracks(withMediaType: AVMediaTypeVideo)
            
            
            assetTracks.forEach({ z in
                print("Asset TRACKS: \(z)")
            })
            
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
            
                
                instruction.timeRange = assetRange
                
                let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: assetTrack)
                
                videoLayerInstruction.setTransform(firstTransform, at: nextTime)
                
                instruction.layerInstructions = [videoLayerInstruction]

                nextTime = CMTimeAdd(nextTime, duration)
                
                frame += 1
            }
        })
    
        self.mutableVideoComposition.renderSize =  CGSize(width: videoTrack.naturalSize.width, height: videoTrack.naturalSize.height)
        
        self.mutableVideoComposition.instructions.append(instruction)

        let parentLayer = CALayer()
        let videoLayer = CALayer()
        
        parentLayer.frame = CGRect(x: 0, y: 0, width: self.mutableVideoComposition.renderSize.width, height: self.mutableVideoComposition.renderSize.height)
        
        videoLayer.frame = CGRect(x: 0, y: 0, width: self.mutableVideoComposition.renderSize.width, height: self.mutableVideoComposition.renderSize.height)
        
        
        parentLayer.addSublayer(videoLayer)
        
        //let animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        //let v = AVVideoCompositionCoreAnimationTool.init()
        
        // mutableVideoComposition.animationTool = v
        
        // Set the frame duration to an appropriate value (i.e. 30 frames per second for video).
        self.mutableVideoComposition.frameDuration = CMTimeMake(1,30);
    
        
        
//        composition.tracks.forEach({ m in
//            print("Composition Track: \(m)")
//            m.segments.forEach({ z in
//                print("Segments: \(z)")
//            })
//        })
        
        self.setupPlayer()
    }
    
    
    func setupPlayer() {
    
        let playerItem = AVPlayerItem(asset: self.composition.copy() as! AVAsset)
        
        // playerItem.videoComposition = mutableVideoComposition
        
        let avPlayer = AVPlayer(playerItem: playerItem)
        
        self.player = avPlayer
        self.player?.volume = 0.0
        self.playerView.player = self.player
        
        self.playerView.player?.addObserver(self,
                                            forKeyPath: #keyPath(AVPlayerItem.status),
                                            options: [.old, .new],
                                            context: &playerViewControllerKVOContext)
        
        
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
        
        
        
        if keyPath == #keyPath(AVPlayerItem.status) {
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
                 
                break
            case .failed:
                // Player item failed. See error.
                
                print("Player Failed")
                break
                
            case .unknown:
                print("Player Unkown");
                
                break
                // Player item is not yet ready.
            }
        }
        
        if keyPath == #keyPath(AVPlayerItem.duration) {
         
        } else if keyPath == #keyPath(AVPlayer.rate) {
           
//            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
//            if(newRate != 0.0) {
//                self.appDelegate.videoControlsController.startTimer()
//            } else {
//                self.appDelegate.videoControlsController.stopTimer()
//            }
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
               //  handleErrorWithMessage(self.player.currentItem?.error?.localizedDescription, error:self.player.currentItem?.error)
            }
        }
    }
    
}
