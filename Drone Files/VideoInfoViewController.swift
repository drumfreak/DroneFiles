//
//  VideoInfoViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 6/8/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz
import CoreData


class VideoInfoViewController: NSViewController {
    
    @IBOutlet var fileNameLabel: NSTextField!
    @IBOutlet var fileSizeLabel: NSTextField!
    @IBOutlet var fileDateLabel: NSTextField!
    @IBOutlet var videoSizeLabel: NSTextField!
    @IBOutlet var videoLocationLabel: NSTextField!
    @IBOutlet var videoFrameRateLabel: NSTextField!
    @IBOutlet var videoDurationLabel: NSTextField!
    @IBOutlet var videoFavoriteButton: NSButton!
    let sizeFormatter = ByteCountFormatter()
    var managedObjectContext: NSManagedObjectContext!
    var mediaMapWindowController: MediaMapWindowController!
    var currentVideoFile: VideoFile!
    var videoManager = VideoFileManager()
    
    
    var currentFile: URL? {
        didSet {
            guard let currentFile = currentFile else { return }
            print("CURRENT URL: \(currentFile)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.videoInfoViewController = self
        managedObjectContext = self.appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if(self.appDelegate.videoPlayerViewController?.currentVideoURL == nil) {
            return
        }
        
        loadFile(url: (self.appDelegate.videoPlayerViewController?.currentVideoURL!)!)
    }
    
    func loadFile(url: URL) {
        // print("URL LOADFILE \(url)")
        
        let videoFile = self.videoManager.getVideoFile(url: url)
        
        self.currentVideoFile = videoFile
        print(videoFile)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        self.fileNameLabel?.stringValue = videoFile.fileName!
        self.fileSizeLabel?.stringValue = "Size: \(sizeFormatter.string(fromByteCount: Int64(videoFile.fileSize)))"
        self.fileDateLabel?.stringValue = "Date: \(dateFormatter.string(from: videoFile.fileDate! as Date))"
        
        var locationLabel = "No Location"
        
        if(videoFile.videoLocation != nil) {
            locationLabel = videoFile.videoLocation!
            print("Location bitches! \(videoFile.videoLocation!)")
        }
        self.videoLocationLabel?.stringValue = "Location: \(locationLabel)"
        
        
        let (h,m,s,_) = self.appDelegate.secondsToHoursMinutesSeconds(seconds: Int(round(videoFile.videoLength)))
        
        self.videoDurationLabel?.stringValue = "Length: " + String(format: "%02d", h) + "h:" + String(format: "%02d", m) + "m:" + String(format: "%02d", s) + "s"
        
        
        self.videoSizeLabel?.stringValue = "Size: \(String(format: "%.0f", videoFile.videoWidth)) x \(String(format: "%.0f", videoFile.videoHeight))"
        
        self.videoFrameRateLabel?.stringValue = "FPS: \(videoFile.videoFPS)"
    }
    
    @IBAction func openMap(sender: AnyObject) {
        self.appDelegate.videoDetailsViewController.showMap(url: self.currentFile!)
        print("open map")
    }
    
    @IBAction func removeChapters(sender: AnyObject) {
        self.appDelegate.videoDetailsViewController.removeAllChapters()
    }
    
    
}
