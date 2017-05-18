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
    var nowPlayingURL: URL!
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
        view.wantsLayer = true
        view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor

        self.playerMessageBoxView.wantsLayer = true
        self.playerMessageBoxView.layer?.backgroundColor = self.appSettings.messageBoxBackground.cgColor
        self.messageSpinner.startAnimation(self)
        



    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        addObserver(self, forKeyPath: #keyPath(playerItem.duration), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(player.rate), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(playerItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        // self.deallocObservers(playerItem: (self.playerView?.player)!)
    }

    
    func setupPlayer() {
        // self.playerView.showsFrameSteppingButtons = true
        self.playerView.showsSharingServiceButton = true
        self.playerView.showsFullScreenToggleButton = true
        self.playerView.player = AVPlayer(playerItem: self.playerItem)
        
        self.playerView.player?.addObserver(self,
                                            forKeyPath: #keyPath(AVPlayerItem.status),
                                            options: [.old, .new],
                                            context: &playerViewControllerKVOContext)
        
        self.playerView.player?.addObserver(self,
                                            forKeyPath: #keyPath(AVPlayer.rate),
                                            options: [.old, .new],
                                            context: &playerViewControllerKVOContext)
        
        let avPlayerLayer = AVPlayerLayer(player: self.playerView.player!)
        avPlayerLayer.frame = self.view.bounds
        
        
    }
    
    func playVideo(_url: URL, frame: CMTime, startPlaying: Bool) {
        // print("Play Video function")
        if(startPlaying) {
            self.startPlayingVideo = true // passes off to after player is ready.
        }
        
        prepareToPlay(_url: _url, startTime: frame)
        
        let location = self.getLocationData(asset: self.currentAsset)
        self.appDelegate.videoPlayerControlsController?.metadataLocationLabel.stringValue = location
        
        // print("Location: \(location)")

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

        let playerItem = AVPlayerItem(asset: asset,
                                      automaticallyLoadedAssetKeys: assetKeys)
        playerItem.reversePlaybackEndTime = kCMTimeZero
        playerItem.forwardPlaybackEndTime = playerItem.duration
        
        if(self.playerView.player?.currentItem == nil) {
            self.playerItem = playerItem
            self.setupPlayer()
        } else {
            self.playerView.player?.replaceCurrentItem(with: playerItem)
        }

        self.appDelegate.videoPlayerControlsController?.calculateClipLength()
        
    }
    
    func deallocObservers(playerItem: AVPlayer) {
        if(self.playerIsReady) {
            self.playerIsReady = false
            print("Deallocating Observers from playerItem")
            self.playerView.player?.pause()
            
            self.playerView.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerViewControllerKVOContext)
            
            self.playerView.player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: &playerViewControllerKVOContext)
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
                // Player item is ready to play.
                // print("Player Ready")
                self.playerIsReady = true
                self.appDelegate.videoPlayerControlsController?.calculateClipLength()
                
                if(self.startPlayingVideo) {
                    self.playerView.player?.play()
                    self.playerView.player?.rate = Float(self.videoRate)
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
                // Player item is not yet ready.
            }
        }
        
        if keyPath == #keyPath(AVPlayerItem.duration) {
            // print("Duration... key")
            //startTimeLabel.isEnabled = hasValidDuration
            //startTimeLabel.text = createTimeString(time: currentTime)
            
            //durationLabel.isEnabled = hasValidDuration
            //durationLabel.text = createTimeString(time: Float(newDurationSeconds))
        } else if keyPath == #keyPath(AVPlayer.rate) {
            // Update `playPauseButton` image.
            // print("Hey rate is changing!");
            
            let newRate = (change?[NSKeyValueChangeKey.newKey] as! NSNumber).doubleValue
            if(newRate != 0.0) {
                self.appDelegate.videoPlayerControlsController?.startTimer()
            } else {
                self.appDelegate.videoPlayerControlsController?.stopTimer()
            }
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
    
    override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        let affectedKeyPathsMappingByKey: [String: Set<String>] = [
            "duration":     [#keyPath(AVPlayerItem.duration)],
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

