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
    
    
    // Allow view to receive keypress (remove the purr sound)
    override var acceptsFirstResponder : Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // self.VideoEditView.isHidden = false
        self.appDelegate.videoPlayerViewController = self
        
        //DispatchQueue.main.async {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.playerMessageBoxView.wantsLayer = true
        self.playerMessageBoxView.layer?.backgroundColor = self.appSettings.messageBoxBackground.cgColor

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
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
        self.playerView.showsSharingServiceButton = true
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
                                            forKeyPath: #keyPath(AVPlayer.rate),
                                            options: [.old, .new],
                                            context: &playerViewControllerKVOContext)
        
        
    }
    
    func playerItemDidPlayToEndTime(sender: AnyObject) {
        if(self.appSettings.mediaBinSlideshowRunning) {
            self.appDelegate.mediaBinCollectionView.nextSlideAfterVideo()
        } else {
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
        
        if(self.player != nil) {
            if((self.player?.rate)! > Float(0)) {
                self.playPause()
            }
        }
        
       
        prepareToPlay(_url: _url, startTime: frame)
        
        let location = self.getLocationData(asset: self.currentAsset)
        self.appDelegate.videoControlsController.metadataLocationLabel?.stringValue = location
        
        // print("Location: \(location)")
    }
    
    // Video Player Setup and Play
    func prepareToPlay(_url: URL, startTime: CMTime) {
        
        let url = _url
        self.currentVideoURL = url
        let asset = AVAsset(url: url)
        
        if(!asset.isPlayable) {
            
            self.playerView.isHidden = true
            let myPopup: NSAlert = NSAlert()
            
            myPopup.messageText = "Video is not playable :/"
            myPopup.informativeText = "The monkeys have verified that something is wrong with this file."
            myPopup.alertStyle = NSAlertStyle.warning
            myPopup.addButton(withTitle: "OK")
            myPopup.runModal()
            return
        } else {
            self.playerView.isHidden = false
        }
        
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
                locationData = (metaDataItems.value as! NSString) as String
            }
        }
        
        return locationData
    }
    
    
    
    // Player stuff
    
    func handleErrorWithMessage(_ message: String?, error: Error? = nil) {
        //  print("Error occured with message: \(message), error: \(error).")
        //  print("Error occured with message: \(message?)")
    }
    
    
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
                NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
                
                
                self.playerIsReady = true
                self.appDelegate.videoControlsController.calculateClipLength()
                self.playerView.becomeFirstResponder()
                if(self.startPlayingVideo == true) {
                    // self.playerView.becomeFirstResponder()
                    self.player.rate = Float(self.videoRate)
                    self.startPlayingVideo = false
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
            }
        }
        
        if keyPath == #keyPath(player.currentItem.duration) {
            
            
        } else if keyPath == #keyPath(AVPlayer.rate) {
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

