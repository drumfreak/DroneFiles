//
//  ViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa
import AVKit
import AppKit
import AVFoundation


class ViewController: NSViewController {

    @IBOutlet var topView: NSView!
    @IBOutlet weak var statusLabel: NSTextField!
    
    // Directories!
    var directory: Directory?
    var startingDirectory = URL(string: "file:///Volumes/NO%20NAME/DCIM/100MEDIA")
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    
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
    
    // Video Player Stuff
    @IBOutlet var playerItem: AVPlayerItem!
    var currentVideoURL: URL!
    @IBOutlet var originalPlayerItem: AVPlayerItem!
    @IBOutlet var player: AVPlayer!
    var nowPlayingURLString: String!
    var nowPlayingURL: URL!
    @IBOutlet weak var nowPlayingFile: NSTextField!
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var trimmedClipNewLabel: NSTextField!
    @IBOutlet weak var trimmedClipNewPathLabel: NSTextField!
    @IBOutlet weak var videoLengthLabel: NSTextField!
    
    var playerItemContext = 0

    // Video Trimming
    @IBOutlet var saveNewItemPreserveDate: NSButton!
    @IBOutlet var saveClipLoadNewItemCheckbox: NSButton!
    @IBOutlet var saveTrimmedClipView: NSView!
    // @IBOutlet weak var exportSession: AVAssetExportSession!
    @IBOutlet weak var clipTrimTimer: Timer!
    @IBOutlet weak var saveTrimmedVideoButton: NSButton!
    @IBOutlet weak var cancelTrimmedVideoButton: NSButton!
    let sizeFormatter = ByteCountFormatter()
    var userTrimmed = false
    var isTrimming = false
    var clippedItemPreserveFileDates = true
    var clippedItemLoadNewItem = true
    var startPlayingVideo = true
    var playerIsReady = false
    
    // var exportSession: AVAssetExportSession!
    
    @IBOutlet var clipTrimProgressBar: NSProgressIndicator!
    

    // Tableviews - File List
    @IBOutlet var tableView: NSTableView!
    var sortOrder = Directory.FileOrder.Name
    var sortAscending = true
    
    // Other Views
    @IBOutlet var VideoEditView: NSView!
    @IBOutlet var PhotoEditView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.VideoEditView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        statusLabel.stringValue = ""
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM-dd-YYYY"
        
        let now = dateformatter.string(from: NSDate() as Date)
        
        dateField.stringValue = now
        
        self.flightName.stringValue = "Drone Flight"
        self.flightNameVar = flightName.stringValue
        self.dateNameVar = dateField.stringValue
        self.saveTrimmedClipView.isHidden = true
        
        self.saveDirectoryName = self.dateNameVar + " - " + self.flightNameVar
        
        self.showNotification(messageType: "default", customMessage: "");
        
        self.saveTrimmedVideoButton.isHidden = true
        setupProjectDirectory()

        let descriptorName = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
        let descriptorDate = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: true)
        let descriptorSize = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)
        
        tableView.tableColumns[0].sortDescriptorPrototype = descriptorName
        tableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
        tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
        
        self.representedObject = self.startingDirectory
        self.folderURL = self.startingDirectory?.absoluteString
        let tmp = self.folderURL.replacingOccurrences(of: "file://", with: "")
        self.folderURLDisplay.stringValue = tmp.replacingOccurrences(of: "%20", with: " ")
        
        reloadFileList()
        
    }

    // Open directory for tableview
    @IBAction func openDocument(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                //print(openPanel.urls)
            }
            self.representedObject = openPanel.url
            
            let tmp = openPanel.url?.absoluteString.replacingOccurrences(of: "file://", with: "")
            self.folderURLDisplay.stringValue = (tmp!.replacingOccurrences(of: "%20", with: " "))
        })
    }
    
    // Helper Functions
    func setupProjectDirectory() {
        self.flightNameVar = self.flightName.stringValue
        self.dateNameVar = self.dateField.stringValue
        self.newFileNamePath.stringValue = dateField.stringValue + " - " + flightName.stringValue
        self.saveDirectoryName =  self.newFileNamePath.stringValue
    }
    
    
    
    // Button and Input Text Actions
    @IBAction func flightNameChanged(sender: AnyObject) {
        // print("Flight Name Changed!");
        //print("Sender " + self.flightName.stringValue)
        setupProjectDirectory()
    }
    
    @IBAction func dateNameChanged(swnder: AnyObject) {
       // print("Date Name Changed!");
       // print("Sender " + self.dateField.stringValue)
        setupProjectDirectory()

    }
    
    
    // Overrides
    
//    override func keyDown(with event: NSEvent) {
//        if (event.keyCode == 53){
//            print("ESC KEY hit");
//            //do whatever when the s key is pressed
//        }
//    }
    
    override var representedObject: Any? {
        didSet {
            if let url = representedObject as? URL {
                // print("Represented object: \(url)")
                directory = Directory(folderURL: url)
                reloadFileList()
                self.folderURL = url.absoluteString
                let tmp = url.absoluteString.replacingOccurrences(of: "file://", with: "")
                // print("TMP" + tmp)
                self.folderURLDisplay.stringValue = tmp.replacingOccurrences(of: "%20", with: " ")
                
            }
        }
    }
    
    
    // Video Clipping
    func getClippedVideosIncrement(_folder: String) -> String {
        var incrementer = "00"
        if FileManager.default.fileExists(atPath: self.clippedVideoPath) {
            // print("url is a folder url")
            // lets get the folder files
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.clippedVideoPathFullURL)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%02d", files.count)
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func getClippedVideoPath(_videoPath : String) -> String {
        
        self.clippedVideoPathFull = self.folderURL.replacingOccurrences(of: "%20", with: " ")
        self.clippedVideoPathFull = self.clippedVideoPathFull + self.saveDirectoryName!
        self.clippedVideoPathFull = self.clippedVideoPathFull + "/" + self.saveDirectoryName! + " - Clips"
        
        // print("Setting clippedVideoPathFull to... " + self.clippedVideoPathFull)

        self.clippedVideoPath = self.clippedVideoPathFull.replacingOccurrences(of: "file://", with: "")

        // print("Setting clippedVideoPath to... " + self.clippedVideoPath)

        
        self.clippedVideoPathFullURL = self.clippedVideoPathFull.replacingOccurrences(of: " ", with: "%20")
        
        // print("Setting clippedVideoNameFullURL to... " + self.clippedVideoPathFullURL)

        
        let increment = getClippedVideosIncrement(_folder: self.clippedVideoPathFullURL)
        
        self.clippedVideoName = self.dateNameVar
        self.clippedVideoName = self.clippedVideoName + " - " + self.flightNameVar
        self.clippedVideoName = self.clippedVideoName + " - Clip " + increment + ".MOV"
        
        // print("Setting clippedVideoName to... " + self.clippedVideoName)

        
        self.clippedVideoNameFull = self.clippedVideoPathFull + "/" + self.clippedVideoName
    
        // print("Setting clippedVideoNameFull to... " + self.clippedVideoName)
        
        self.clippedVideoNameFullURL = self.clippedVideoNameFull.replacingOccurrences(of: " ", with: "%20")
    
        // print("Setting clippedVideoNameFullURL to... \(self.clippedVideoNameFullURL)")
        
        
        // CHECK HERE IF FILE EXISTS  - RENAME
        // print("Looking for URL: " + self.clippedVideoNameFull)
        
        if FileManager.default.fileExists(atPath: self.clippedVideoNameFull.replacingOccurrences(of: "file://", with: "")) {
            print("Fuck that file exists..")
        
            let incrementer = "00000"
                
            self.clippedVideoName = self.dateNameVar
            self.clippedVideoName = self.clippedVideoName + " - " + self.flightNameVar
            self.clippedVideoName = self.clippedVideoName + " - Clip " + increment + "-" + incrementer + ".MOV"
            
            // print("Setting clippedVideoName to... " + self.clippedVideoName)

            self.clippedVideoNameFull = self.clippedVideoPathFull + "/" + self.clippedVideoName
            
            // print("Setting clippedVideoNameFull to... \(self.clippedVideoNameFullURL)")
            
            self.clippedVideoNameFullURL = self.clippedVideoNameFull.replacingOccurrences(of: " ", with: "%20")
            
            // print("Setting clippedVideoNameFullURL to... \(self.clippedVideoNameFullURL)")


        } else {
             print("That file does not exist..")
        }
        
        self.saveTrimmedClipView.isHidden = false
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
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func calculateClipLength() {
        print("Calling Calculate Clip Length")
        
        if(self.playerView.player?.currentItem?.forwardPlaybackEndTime == kCMTimeInvalid) {
            self.playerView.player?.currentItem?.forwardPlaybackEndTime = (self.playerView.player?.currentItem?.duration)!
        }
        
        if(self.playerView.player?.currentItem?.reversePlaybackEndTime == kCMTimeInvalid) {
            self.playerView.player?.currentItem?.reversePlaybackEndTime = kCMTimeZero
        }
        
        // let clipLength = CMTimeGetSeconds(self.playerItem.duration)
    
        // print("forwardPlaybackEndTime is \(self.playerItem.forwardPlaybackEndTime)")

        // print("reversePlaybackEndTime is \(self.playerItem.reversePlaybackEndTime)")

        let difference = CMTimeSubtract((self.playerView.player?.currentItem?.forwardPlaybackEndTime)!, (self.playerView.player?.currentItem?.reversePlaybackEndTime)!)
        let durationSeconds = CMTimeGetSeconds(difference);
        
        if(durationSeconds > 0) {
            let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: Int(round(durationSeconds)))
            // print ("Trimmed Time: \(h) Hours, \(m) Minutes, \(s) Seconds")
            self.videoLengthLabel.stringValue = String(format: "%02d", h) + "h:" + String(format: "%02d", m) + "m:" + String(format: "%02d", s) + "s"
        } else {
             self.videoLengthLabel.stringValue = "00:00:0000"
        }
        
    }
    
    func doTheTrim() {
        if(!self.isTrimming) {
            self.isTrimming = true
            self.playerView.beginTrimming { result in
                if result == .okButton {
                    self.startTrimming()
                } else {
                    // user selected Cancel button (AVPlayerViewTrimResult.cancelButton)...
                    // print("CANCELLED TRIM");
                    self.cancelTrimmedClip(self.playerView)
                }
            }
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
        
        self.playerView.showsFrameSteppingButtons = true
        self.playerView.showsSharingServiceButton = true
        self.playerView.showsFullScreenToggleButton = true

       
        let playerItem = AVPlayerItem(asset: asset,
                                       automaticallyLoadedAssetKeys: assetKeys)
        playerItem.reversePlaybackEndTime = kCMTimeZero
        playerItem.forwardPlaybackEndTime = playerItem.duration
    
        if(self.playerView.player == nil) {
            print("player is nil")
            
            let player = AVPlayer(playerItem: playerItem)
            
            self.playerView.player = player
            
            // Register as an observer of the player item's status property
            self.playerView.player?.currentItem?.addObserver(self,
                                    forKeyPath: #keyPath(AVPlayerItem.status),
                                    options: [.old, .new],
                                    context: &playerItemContext)
        } else {
            print("player IS NOT nil")
            self.deallocObservers(player: (self.playerView.player?.currentItem!)!)
            self.playerView.player?.replaceCurrentItem(with: playerItem)
        }
    
        // Register as an observer of the player item's status property
        self.playerView.player?.currentItem?.addObserver(self,
                                                         forKeyPath: #keyPath(AVPlayerItem.status),
                                                         options: [.old, .new],
                                                         context: &playerItemContext)
        self.calculateClipLength()
        
        return self.playerView.player!
    }
    
    //observer for av play
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
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
    }
    
    private func deallocObservers(player: AVPlayerItem) {
        if(self.playerIsReady) {
            self.playerIsReady = false
            print("Deallocating Observers from playerItem")
            self.playerView.player?.pause()
            // self.playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            self.playerView.player?.currentItem?.removeObserver(self, forKeyPath:  #keyPath(AVPlayerItem.status), context: &playerItemContext)
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
        
        
        // self.playVideo(_url:self.nowPlayingURL, frame: kCMTimeZero, startPlaying: true)
    }
    
    
    func updateProgressBar(session: Float) {
        
        // let convertedValue = self.exportSession.progress
        print("calling update progress bar..." + String(format: "%02d", session))

        // print("calling update progress bar...\(String(describing: convertedValue))")
        //        if(progress < 1.0) {
        //            self.clipTrimProgressBar.doubleValue = progress
        //        } else {
        //            self.clipTrimProgressBar.doubleValue = 1.0
        //            self.clipTrimProgressBar.stopAnimation(progress)
        //        }
        
    }

    
    func saveClippedFileCompleted() {
        print("Session Completed")
        self.saveTrimmedClipView.isHidden = true
        self.saveTrimmedVideoButton.isHidden = true
        //self.saveTrimmedVideoButton.isEnabled = true
        self.trimmedClipNewLabel.isHidden = true
        self.trimmedClipNewLabel.stringValue = ""
        self.cancelTrimmedVideoButton.isHidden = true
        
        self.showNotification(messageType:"VideoTrimComplete", customMessage: self.clippedVideoPathFullURL)
        
        if(self.clippedItemPreserveFileDates) {
            self.setFileDate(originalFile: (self.nowPlayingURLString)!, newFile: self.clippedVideoNameFull.replacingOccurrences(of: "file://", with: ""))
        }
        
        self.isTrimming = false
        
    }
    
    func saveClippedFileFailed() {
        print("Session FAILED")
        self.saveTrimmedVideoButton.isEnabled = true
        // print ("Error: \(String(describing: exportSession.error))")
    }
    
    func saveClippedFileUnknown() {
        print("I don't know..");
    }

    
    @IBAction func saveTrimmedClip(_ sender: AnyObject?) {
        print ("Saving Trimmed Clip!!");
        self.saveTrimmedVideoButton.isEnabled = false
        self.cancelTrimmedVideoButton.isEnabled = false
        self.flightNameVar = flightName.stringValue
        self.dateNameVar = dateField.stringValue
    
        
        // print("Making new Directory at Path: \(completeMoviePath)")
        do
        {
            try FileManager.default.createDirectory(atPath: self.clippedVideoPath, withIntermediateDirectories: true, attributes: nil)
        }
        catch _ as NSError
        {
            print("Error while creating a folder.")
        }
        
        let exportSession = AVAssetExportSession(asset: (self.playerView.player?.currentItem?.asset)!, presetName: AVAssetExportPresetHighestQuality)!
        
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.outputURL = URL(string: self.clippedVideoNameFullURL)// Output URL
        
        let startTime = self.playerView.player?.currentItem?.reversePlaybackEndTime
        let endTime = self.playerView.player?.currentItem?.forwardPlaybackEndTime
        let timeRange = CMTimeRangeFromTimeToTime(startTime!, endTime!)
    
        exportSession.timeRange = timeRange
      
        self.clipTrimProgressBar.startAnimation(0.0)
        self.clipTrimProgressBar.minValue = 0.0
        self.clipTrimProgressBar.maxValue = 1.0
        self.clipTrimProgressBar.isIndeterminate = false
        
        self.clipTrimProgressBar.doubleValue = 0.00
        
        // Move to a background thread to do some long running work
        DispatchQueue.global(qos: .userInitiated).async {
            // Bounce back to the main thread to update the UI
            
            print("Running queue damn! \(exportSession.progress)")
            
            DispatchQueue.main.async {
  
                exportSession.exportAsynchronously {
                    print("AVSession progress \(exportSession.progress)")

                    switch exportSession.status {
                        case .completed:
                            // Export Complete
                            self.saveClippedFileCompleted()
                            self.clipTrimTimer.invalidate()
                            break
                        case .failed:
                            // handle others
                            self.saveClippedFileFailed()
                            self.clipTrimTimer.invalidate()
                            break
                            // failed
                        default:
                            self.saveClippedFileUnknown()
                            self.clipTrimTimer.invalidate()
                            break
                    }
                }
                
                self.clipTrimTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(self.updateProgressBar), userInfo: (session: exportSession.progress), repeats: true)
               
                
            }
        }
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//            while (session.status == AVAssetExportSessionStatusExporting) {
//                dispatch_sync(dispatch_get_main_queue(), ^{
//                    self.progressView.progress = session.progress;
//                    });
//            }
//            });
        
        
    }
    
    func setFileDate(originalFile: String, newFile: String) {
        
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        original = original.replacingOccurrences(of: "%20", with: " ");
        
        var modifyFile = newFile.replacingOccurrences(of: "file://", with: "");
        modifyFile = newFile.replacingOccurrences(of: "%20", with: " ");

        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: original)
            let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            // print("Modification date: ", modificationDate)
        
            let attributes = [
                FileAttributeKey.creationDate: modificationDate,
                FileAttributeKey.modificationDate: modificationDate
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
    
    @IBAction func takeScreenshot(_ sender: AnyObject?) {
        print("Taking Screenshot");
        
       // let currentVideoTime = self.playerItem.currentTime()
        self.saveTrimmedClipView.isHidden = true
        
        self.playerView.player?.pause()
        
        // self.playVideo(_url: self.currentVideoURL, frame: currentVideoTime, startPlaying: false)
    }
    
    
    func showNotification(messageType: String, customMessage: String) -> Void {
        
        DispatchQueue.main.async {
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

    
    func reloadFileList() {
        directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        tableView.reloadData()
    }
    
  
    func updateStatus() {
        
        let text: String
        
        // 1
        let itemsSelected = tableView.selectedRowIndexes.count
        
        // 2
        if (directoryItems == nil) {
            text = "No Items"
        }
        else if(itemsSelected == 0) {
            text = "\(directoryItems!.count) items"
        }
        else {
            text = "\(itemsSelected) of \(directoryItems!.count) selected"
        }
        
        // 3
        statusLabel.stringValue = text
        // print("Selected Text : \(text)");
    }

    func tableViewDoubleClick(_ sender:AnyObject) {
        
        // 1
        guard tableView.selectedRow >= 0,
            let item = directoryItems?[tableView.selectedRow] else {
                return
        }
        
        if item.isFolder {
            // 2
            self.representedObject = item.url as Any
        }
        else {
            
            // print("SELECTED ITEM IS \(item)");
            // 3
            
            let url = NSURL(fileURLWithPath: item.url.absoluteString)
            
            let _extension = url.pathExtension
            
            if(_extension == "MOV" || _extension == "mov" || _extension == "mp4" || _extension == "MP4" || _extension == "m4v" || _extension == "M4V") {
                self.VideoEditView.isHidden = false;
                playVideo(_url: item.url as URL, frame:kCMTimeZero, startPlaying: true);
                nowPlayingFile.stringValue = item.name;
                var itemUrl = (item.url as URL).absoluteString
                self.nowPlayingURL = (item.url as URL)
                
                itemUrl = itemUrl.replacingOccurrences(of: "file://", with: "")
                self.nowPlayingURLString = itemUrl
                print("~~~~~~~~~~~~~~~~~~~~~~~ NOW PLAYING: " + itemUrl)
                
            } else {
                 self.VideoEditView.isHidden = true;
            }
            
           
            // NSWorkspace.shared().open(item.url as URL)
        }
    }
    
    
//    fileprivate func generateThumnail(url : URL, fromTime:Float64) -> NSImage? {
//        let asset :AVAsset = AVAsset(url: url)
//        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
//        assetImgGenerate.appliesPreferredTrackTransform = true
//        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero;
//        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero;
//        let time        : CMTime = CMTimeMakeWithSeconds(fromTime, 600)
//        var img: CGImage?
//        do {
//            img = try assetImgGenerate.copyCGImage(at:time, actualTime: nil)
//        } catch {
//        }
//        if img != nil {
//            let frameImg    : NSImage = NSImage(cgImage: img!)
//            return frameImg
//        } else {
//            return nil
//        }
//    }

}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return directoryItems?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        // 1
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        if let order = Directory.FileOrder(rawValue: sortDescriptor.key!) {
            // 2
            sortOrder = order
            sortAscending = sortDescriptor.ascending
            reloadFileList()
        }
    }
    
}

extension ViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        static let DateCell = "DateCellID"
        static let SizeCell = "SizeCellID"
        static let KindCell = "KindCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        

        // 1
        guard let item = directoryItems?[row] else {
            return nil
        }
        
        // print(item);
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
                       image = item.icon
            text = item.name
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = dateFormatter.string(from: item.date)
            cellIdentifier = CellIdentifiers.DateCell
        } else if tableColumn == tableView.tableColumns[2] {
            text = item.isFolder ? "--" : sizeFormatter.string(fromByteCount: item.size)
            cellIdentifier = CellIdentifiers.SizeCell
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

