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
    @IBOutlet var saveTimeLapseButton: NSButton!
    @IBOutlet var durationLabel: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    @IBOutlet var videoSizeSelectMenu: NSPopUpButton!
    @IBOutlet var videoFrameRateSelectMenu: NSPopUpButton!
    @IBOutlet var outputFolderLabel: NSTextField!
    @IBOutlet var outputFileName: NSTextField!
    @IBOutlet var progressLabel: NSTextField!

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
    
    
    var videoSizes: [NSSize] = [
        NSSize(width: 1024, height: 576),
        NSSize(width: 1152, height: 648),
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

    
    var videoFrameRateSelectMenuOptions = ["1", "2", "5", "10", "15", "20", "24", "30", "60", "120"]
    
    
    var frameRates = [1, 2, 5, 10, 15, 20, 24, 30, 60, 120]
    
    
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
        
        DispatchQueue.main.async {
            self.progressIndicator.isHidden = true
            if(self.receivedFiles.count > 2) {
                self.saveTimeLapseButton.isHidden = false
            }
        }
        
        self.videoSizeSelectMenu.addItems(withTitles: self.videoSizeSelectMenuOptions)
        
        self.videoSizeSelectMenu.selectItem(at: 5)
        
        self.videoFrameRateSelectMenu.addItems(withTitles: self.videoFrameRateSelectMenuOptions)
        
        self.videoFrameRateSelectMenu.selectItem(at: 3)


        self.outputFolderLabel.stringValue = self.appSettings.timeLapseFolder.replacingOccurrences(of: self.appSettings.projectFolder, with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: "/Volumes", with: "")
        
        self.progressLabel.isHidden = true
        self.progressLabel.stringValue = "0%"
        self.getTimeLapseUrl()

    }

    func getTimeLapseUrl() {
        
        let framerate = self.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]
        
        let size = self.videoSizes[self.videoSizeSelectMenu.indexOfSelectedItem]
        
        print("size \(String(describing: size))")
        
        print("framerate \(String(describing: framerate))")
    
        let sizeAndWidth =  "\(Int32(size.width))x\(Int32(size.height))-\(framerate)fps"
        
        let _ = self.generateTimeLapseURL(sizeAndWidth: sizeAndWidth)
        
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
            self.progressLabel.stringValue = "0.0%"
            self.progressLabel.isHidden = true
            if(!err) {
                self.appDelegate.appSettings.mediaBinUrls.append(url)
                
                let notification = NSUserNotification()
                // notification.identifier = "timelapse290239"
                notification.title = "Timelapse Saved!"
                notification.informativeText = "Filename.... "
                notification.soundName = NSUserNotificationDefaultSoundName
                notification.actionButtonTitle = "Oh yeah"
                notification.hasActionButton = true
                
                self.appDelegate.notificationCenter.deliver(notification)
                
                
            }
        }
    }
    
    @IBAction func writeTimeLapse(_ sender: AnyObject) {
        
        print("rate: \(String(describing: self.videoFrameRateSelectMenu.indexOfSelectedItem))")
   

        self.saveTimeLapseButton.isEnabled = false
        
        self.progressIndicator.isHidden = false
        
        self.progressIndicator.doubleValue = 0.00
        
        self.progressLabel.isHidden = false
        
        self.progressLabel.stringValue = "0%"

        
        let framerate = self.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]
        
        
        let size = self.videoSizes[self.videoSizeSelectMenu.indexOfSelectedItem]
        
        print("size \(String(describing: size))")
        
        print("framerate \(String(describing: framerate))")
        
        
        let sizeAndWidth =  "\(Int32(size.width))x\(Int32(size.height))-\(framerate)fps"
        
        let timeLapseUrl = self.generateTimeLapseURL(sizeAndWidth: sizeAndWidth)
        
        let builder = TimeLapseBuilder(photoURLs: self.imageUrls, url: timeLapseUrl)
        
        print("New Timelapse video file..." + timeLapseUrl)
        
        builder.build(frameRate: Int32(framerate), outputSize: size, { progress in
            print(progress)
            DispatchQueue.main.async {
                self.progressLabel.stringValue = "\(Int32(progress.fractionCompleted))%"
                
                self.progressIndicator.doubleValue = progress.fractionCompleted
                
            }
        }, success: { url in
            print(url)
            self.finishSave(false, url: url)
           // DispatchQueue.main.async {

            
           

           //  }
            // notification.but
                // = [NSUserNotificationAction.init(identifier: "notificationAction", title: "View Now")]
            
            
            
            
        }, failure: { error in
            print(error)
            self.finishSave(true, url: URL(string: timeLapseUrl)!)
        })
    }
    
    func notificationAction() {

        print("Fuck this works!")
    
    }
    
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
    
    func generateTimeLapseURL(sizeAndWidth: String) -> String {
  
        let increment = getClippedVideosIncrement(folder: self.appDelegate.appSettings.timeLapseFolder)
        
        self.timelapseVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Timelapse \(increment) - \(sizeAndWidth).mp4"
    
        let timelapseFullPath = self.appDelegate.appSettings.timeLapseFolder + "/" + self.timelapseVideoName.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: timelapseFullPath.replacingOccurrences(of: "file://", with: "")) {
            print("Fuck that file exists..")
            
            let incrementer = "00000"
           
            self.timelapseVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Timelapse \(increment) - \(incrementer) - \(sizeAndWidth).mp4"
            
        } else {
            print("That file does not exist..")
        }
        
        let timeLapseUrl = self.appDelegate.appSettings.timeLapseFolder + "/" + self.timelapseVideoName.replacingOccurrences(of: " ", with: "%20")
        
        self.outputFileName.stringValue = URL(string: timeLapseUrl)!.lastPathComponent
        
        print("So far I came up with: \(timeLapseUrl)")

        return timeLapseUrl.replacingOccurrences(of: " ", with: "%20")
    }
    
    func setFileDate(originalFile: String, newDate: Date) {
        // print("ORIGINAL FILE.... \(originalFile)")
        
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        
        original = original.replacingOccurrences(of: "%20", with: " ");
        
        do {
            
            let attributes = [
                FileAttributeKey.creationDate: newDate,
                FileAttributeKey.modificationDate: newDate
            ]
            
            do {
                try FileManager.default.setAttributes(attributes, ofItemAtPath: original)
            } catch {
                print(error)
            }
        }
    }

    
    
}
