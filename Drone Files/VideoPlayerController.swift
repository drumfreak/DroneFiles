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
    @IBOutlet weak var playerView: AVPlayerView!
    
    // Video Player Stuff
    var playerItem: AVPlayerItem!
    var currentVideoURL: URL!
    @IBOutlet var originalPlayerItem: AVPlayerItem!
    @IBOutlet var player: AVPlayer!
    var nowPlayingURL: URL! {
        didSet {
            self.playVideo(_url: nowPlayingURL, frame:kCMTimeZero, startPlaying: self.appSettings.videoPlayerAlwaysPlay);
        }
    }
    
    var currentAsset: AVAsset!
    var startPlayingVideo = true
    var playerIsReady = false
    
    var videoRate = 1.0
    
    @IBOutlet weak var playerMessageBox: NSBox!
    @IBOutlet weak var playerMessageBoxView: NSView!
    
    @IBOutlet weak var playerMessageBoxLabel: NSTextField!
    var playerViewControllerKVOContext = 0
    
    @IBOutlet weak var messageSpinner: NSProgressIndicator!
    
    
//    // Allow view to receive keypress (remove the purr sound)
//    override var acceptsFirstResponder : Bool {
//        return true
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.VideoEditView.isHidden = false
        self.appDelegate.videoPlayerViewController = self
        
        //DispatchQueue.main.async {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.playerMessageBoxView.wantsLayer = true
        self.playerMessageBoxView.layer?.backgroundColor = self.appSettings.messageBoxBackground.cgColor
        //self.playerView.becomeFirstResponder()

        // }
        //  self.messageSpinner.startAnimation(self)
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
//        addObserver(self, forKeyPath: #keyPath(playerItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
//        
//        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
//        
//        addObserver(self, forKeyPath: #keyPath(playerItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
//        
        //self.playerView.becomeFirstResponder()

        // print("Video appeared")
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        // self.appDelegate.saveProject()
        
        if(self.playerView.player != nil) {
            if(self.playerView.player?.isPlaying)! {
                self.playerView.player?.pause()
                self.playerView.resignFirstResponder()
            }
        }
        
    }
    
    
    func playPause() {
        //        if(!self.playerIsReady) {
        //            return
        //        }
        
        if(self.player.isPlaying) {
            self.player.pause()
            // self.playerView.resignFirstResponder()
        } else {
            self.player.rate = Float(self.videoRate)
            self.playerView.becomeFirstResponder()
        }
        
        

    }
    
    func setupPlayer() {
        // self.playerView.showsFrameSteppingButtons = true
        self.playerView.showsSharingServiceButton = false
        self.playerView.showsFullScreenToggleButton = true
        //self.playerView.becomeFirstResponder()
        
        self.player = AVPlayer(playerItem: self.playerItem)
        
        self.player.volume = 0.0
        self.playerView.player = self.player
        
        
        self.playerView.player?.currentItem!.addObserver(self,
                                            forKeyPath: #keyPath(player.currentItem.status),
                                            options: [.old, .new],
                                            context: &playerViewControllerKVOContext)
        
        self.playerView.player?.addObserver(self,
                                            forKeyPath: #keyPath(player.rate),
                                            options: [.old, .new],
                                            context: &playerViewControllerKVOContext)
        
        // let avPlayerLayer = AVPlayerLayer(player: self.player!)
        // avPlayerLayer.frame = self.view.bounds
        
        //self.playerView.becomeFirstResponder()

        
        
    }
    
    func playerItemDidPlayToEndTime(sender: AnyObject) {
        // self.playerView.player?.play()
        
        
        if(self.appSettings.mediaBinSlideshowRunning) {
            
            self.appDelegate.mediaBinCollectionView.nextSlideAfterVideo()

        } else {
            
            // Play next
            // Loop all next.
            if(self.appSettings.videoPlayerLoop) {
                self.player.seek(to: kCMTimeZero)
                self.player.rate = Float(self.videoRate)
            } else {
                self.player.seek(to: kCMTimeZero)
            }
        }
        
        
    }
    
    
    func playVideo(_url: URL, frame: CMTime, startPlaying: Bool) {
        // print("Play Video function")
        if(startPlaying == true) {
            self.startPlayingVideo = true // passes off to after player is ready.
        } else {
            self.startPlayingVideo = false
        }
        
        prepareToPlay(_url: _url, startTime: frame)
        
        let location = self.getLocationData(asset: self.currentAsset)
        self.appDelegate.videoControlsController.metadataLocationLabel?.stringValue = location
        
        // print("Location: \(location)")
        //self.playerView.becomeFirstResponder()

        
    }
    
    // Video Player Setup and Play
    func prepareToPlay(_url: URL, startTime: CMTime) {
        
        let url = _url
        self.currentVideoURL = url
        let asset = AVAsset(url: url)
        
        let assetKeys = [
            "playable",
            "hasProtectedContent"
        ]
        
        self.currentAsset = asset
        
        let pi = AVPlayerItem(asset: asset,
                                      automaticallyLoadedAssetKeys: assetKeys)
        
        pi.reversePlaybackEndTime = kCMTimeZero
        pi.forwardPlaybackEndTime = pi.duration
        
        if(self.playerView.player?.currentItem == nil) {
            self.playerItem = pi
            self.setupPlayer()
        } else {
            
            self.player?.currentItem!.removeObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: &playerViewControllerKVOContext)

            
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            
            
            
            self.playerView.player?.replaceCurrentItem(with: pi)
            
            self.playerItem = pi
            
            self.playerView.player?.currentItem!.addObserver(self,
                                                forKeyPath: #keyPath(player.currentItem.status),
                                                options: [.old, .new],
                                                context: &playerViewControllerKVOContext)
            
            self.playerView.player?.addObserver(self,
                                                forKeyPath: #keyPath(AVPlayer.rate),
                                                options: [.old, .new],
                                                context: &playerViewControllerKVOContext)
            
            
            if(self.startPlayingVideo == true) {
                self.player.rate = Float(self.videoRate)
                // self.startPlayingVideo = false
            } else {
                
                if(self.player.isPlaying) {
                    self.player.rate = 0.0
                }
                self.startPlayingVideo = false
                
            }
            
            
        }
        
        self.appDelegate.videoControlsController.calculateClipLength()
        
    }
    
    func deallocObservers(playerItem: AVPlayer) {
        if(self.playerIsReady) {
            self.playerIsReady = false
            print("Deallocating Observers from playerItem")
            self.player.pause()
            
            self.player?.currentItem!.removeObserver(self, forKeyPath: #keyPath(player.currentItem.status), context: &playerViewControllerKVOContext)
            
            self.player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: &playerViewControllerKVOContext)
        }
    }
    
    
    func getLocationData(asset: AVAsset) -> String {
        
        var locationData = ""
        
        for metaDataItems in asset.commonMetadata {
            if metaDataItems.commonKey == "location" {
                //print("ASSET METADATA");
                //print("Common Key: \(String(describing: metaDataItems.commonKey))")
                locationData = (metaDataItems.value as! NSString) as String
                // print("Location Data: \(locationData)")
            }
        }
        
        return locationData
        
    }
    
    
    
    // Player stuff
    
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
            
            // Switch over the status
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                // print("Player Ready")
                
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
                
                
                self.playerIsReady = true
                self.appDelegate.videoControlsController.calculateClipLength()
                
                if(self.startPlayingVideo == true) {
                    // self.playerView.becomeFirstResponder()
                    self.player.rate = Float(self.videoRate)
                    self.startPlayingVideo = false
                } else {
                    
                    if(self.player.isPlaying) {
                        self.player.rate = 0.0
                    }
                    self.startPlayingVideo = false
                    self.appDelegate.videoControlsController.calculateClipLength()
                }
                
                break
            case .failed:
                // Player item failed. See error.
                
                print("Player Failed")
                self.playerIsReady = false
                break
                
            case .unknown:
                print("Player Unkown");
                self.playerIsReady = false
                
                break
                // Player item is not yet ready.
            }
        }
        
        if keyPath == #keyPath(player.currentItem.duration) {
            
            
        } else if keyPath == #keyPath(AVPlayer.rate) {
            // Update `playPauseButton` image.
            // print("Hey rate is changing!");
            
            print("12345 This is happening...")
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            if(newRate != 0.0) {
                self.appDelegate.videoControlsController.startTimer()
            } else {
                self.appDelegate.videoControlsController.stopTimer()
            }
        }
    }
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let affectedKeyPathsMappingByKey: [String: Set<String>] = [
            "duration":     [#keyPath(player.currentItem.duration)],
            "rate":         [#keyPath(AVPlayer.rate)]
        ]
        
        return affectedKeyPathsMappingByKey[key] ?? super.keyPathsForValuesAffectingValue(forKey: key)
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

