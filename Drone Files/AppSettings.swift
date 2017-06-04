//
//  AppSettings.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/15/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa

struct AppSettings {
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    let userDefaults = UserDefaults.standard
    
    var mediaQueueIsOpen = false {
        didSet {
            
        }
    }
    
    var secondDisplayIsOpen = false {
        didSet {
            
        }
    }
    
    
    var mediaBinSlideshowRunning = false {
        didSet {
            
        }
    }
    
    
    var fileManagerIsOpen = false {
        didSet {
            
        }
    }
    
    var fileBrowserIsOpen = false {
        didSet {
            
        }
    }
    
    var mediaBinIsOpen = false {
        didSet {
            
        }
    }
    
    
    var sourceFolder = "file:///Volumes/DroneStick1/DCIM/100MEDIA/"
    var fileSequenceName = ""
    var fileSequenceNameTag = ""
    var projectDirectory = ""
    
    var blockScreenShotTabSwitch = false
    
    var outputDirectory: String! {
        didSet {
            if let output = outputDirectory {
                userDefaults.setValue(output, forKey: "outputDirectory")
            }
        }
    }
    
    
    var thumbnailDirectory: String! {
        didSet {
            if let output = thumbnailDirectory {
                userDefaults.setValue(output, forKey: "thumbnailDirectory")
            }
        }
    }
    
    
    
    var lastFolderOpened: String! {
        didSet {
            if let output = lastFolderOpened {
                userDefaults.setValue(output, forKey: "lastFolderOpened")
            }
        }
    }
    
    
    var lastFileOpened: String! {
        didSet {
            if let output = lastFileOpened {
                userDefaults.setValue(output, forKey: "lastFileOpened")
            }
        }
    }
    
    var lastProjectfileOpened: String! {
        didSet {
            if let output = lastProjectfileOpened {
                userDefaults.setValue(output, forKey: "lastProjectfileOpened")
            }
        }
    }
    
    
    var createProjectDirectory = true
    var createProjectSubDirectories = true
    
    var folderURL: String!
    var saveDirectoryName: String!
    
    var projectFolder = "My Project"
    var screenShotFolder = " - Screenshots"
    var videoFolder = " - Videos"
    var jpgFolder = " - JPG"
    var dngFolder = " - RAW"
    var rawFolder = " - RAW"
    var videoClipsFolder = " - Video Clips"
    var timeLapseFolder = " - TimeLapses"
    var previousUrlString = "file://"

    
    // Video Player
    
    var videoPlayerLoop = Bool(true) {
        didSet {
            userDefaults.setValue(videoPlayerLoop, forKey: "videoPlayerLoop")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var videoPlayerLoopAll = Bool(true) {
        didSet {
            userDefaults.setValue(videoPlayerLoopAll, forKey: "videoPlayerLoopAll")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var videoPlayerAutoPlay = Bool(true) {
        didSet {
            userDefaults.setValue(videoPlayerAutoPlay, forKey: "videoPlayerAutoPlay")
            // self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var videoPlayerAlwaysPlay = Bool(true) {
        didSet {
            userDefaults.setValue(videoPlayerAlwaysPlay, forKey: "videoPlayerAlwaysPlay")
            // self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    
    // Screenshots
    
    var screenShotBurstEnabled = Bool(true) {
        didSet {
            userDefaults.setValue(screenShotBurstEnabled, forKey: "screenShotBurstEnabled")
            // self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var screenshotSound = Bool(true) {
        didSet {
            userDefaults.setValue(screenshotSound, forKey: "screenshotSound")
            // self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    
    var screenshotPreview = Bool(false){
        didSet {
            userDefaults.setValue(screenshotPreview, forKey: "screenshotPreview")
            // self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var screenshotPreserveVideoDate = Bool(true) {
        didSet {
            userDefaults.setValue(screenshotPreserveVideoDate, forKey: "screenshotPreserveVideoDate")
            // self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    
    var screenshotPreserveVideoLocation = Bool(false) {
        didSet {
            userDefaults.setValue(screenshotPreserveVideoLocation, forKey: "screenshotPreserveVideoLocation")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var screenshotPreserveVideoName = Bool(true) {
        didSet {
            userDefaults.setValue(screenshotPreserveVideoName, forKey: "screenshotPreserveVideoName")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    
    var screenshotFramesBefore = Int32(5) {
        didSet {
            userDefaults.setValue(screenshotFramesBefore, forKey: "screenshotFramesBefore")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var screenshotFramesAfter = Int32(5) {
        didSet {
            userDefaults.setValue(screenshotFramesAfter, forKey: "screenshotFramesAfter")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var screenshotFramesInterval = Double(4.0) {
        didSet {
            userDefaults.setValue(screenshotFramesInterval, forKey: "screenshotFramesInterval")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    
    var screenshotTypeJPG = Bool(true) {
        didSet {
            userDefaults.setValue(screenshotTypeJPG, forKey: "screenshotTypeJPG")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    var screenshotTypePNG = Bool(false) {
        didSet {
            userDefaults.setValue(screenshotTypePNG, forKey: "screenshotTypePNG")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    
    // Media Bin Stuff
    
    var mediaBinReverseURLS = Bool(true) {
        didSet {
            userDefaults.setValue(mediaBinReverseURLS, forKey: "mediaBinReverseURLS")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
        }
    }
    
    var mediaBinTimerInterval = Double(4.0) {
        didSet {
            userDefaults.setValue(mediaBinTimerInterval, forKey: "mediaBinTimerInterval")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    
    
    // Media Bin stuff
    var mediaBinUrls = [URL]() {
        didSet {
            let data = NSKeyedArchiver.archivedData(withRootObject: mediaBinUrls)
            
            userDefaults.setValue(data, forKey: "mediaBinUrls")
            
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
            
        }
    }
    
    // Favorites
    var favoriteUrls = [URL]() {
        didSet {
            // print(favoriteUrls)
            let data = NSKeyedArchiver.archivedData(withRootObject: favoriteUrls)
            userDefaults.setValue(data, forKey: "favoriteUrls")
            //self.appDelegate.writeProjectFile(projectPath: self.projectFolder)
            
        }
    }
    
    // THEMES
    
    
    // colors
    var appBackgroundColor = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
     var toolbarBackgroundColor = NSColor.init(patternImage: NSImage(named: "titlebarBackgroundGradient.png")!)
    
    var appViewBackgroundColor = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
    
    
    var themeViewDarkBox1 = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    // Selected row
    var windowTitleBarBackgroundColor = NSColor.init(patternImage: NSImage(named: "titlebarBackgroundBlack.png")!)
    
    var patternColor = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
    var tableViewBackgroundColor = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
    // normal row
    var tableRowBackGroundColor =  NSColor.init(patternImage: NSImage(named: "backgroundSoftBlack.png")!)
    
    // Alternate row
    var tableViewAlternatingRowColor = NSColor.init(patternImage: NSImage(named: "backgroundDarkGray.png")!)
    
    // Selected row
    var tableRowSelectedBackGroundColor = NSColor.init(patternImage: NSImage(named: "tablerow-dark.png")!)
    
    // Active row
    var tableRowActiveBackGroundColor =  NSColor.init(patternImage: NSImage(named: "tablerow-blue.png")!)
    
    // tableHeaderRow
    var tableHeaderRowBackground =  NSColor.init(patternImage: NSImage(named: "tablerow-dark.png")!)
    
    
    // Message Boxes
    // tableHeaderRow
    
    var textLabelColor = NSColor.gray
    
    var messageBoxBackground =  NSColor.init(patternImage: NSImage(named: "messagewindow.png")!)
    
    // Image thumbnail for collection View Backgrounds
    // tableHeaderRow
    var imageThumbnailHolder =  NSColor.init(patternImage: NSImage(named: "messagewindow.png")!)
    
    
    // Split view management
    
    var videoSplitViewIsOpen = false
    var imageEditorSplitViewIsOpen = false
    var fileManagerSplitViewIsOpen = false

    
    
    var videoSizeSelectMenuOptions = [
        "[4:3] - 640 × 480",

        
        "[16:9] - 1024 × 576",
        "[16:9] - 1152 × 648",
        "[16:9] - 1280 x 720 (720HD)",
        "[16:9] - 1366 × 768",
        "[16:9] - 1600 × 900",
        "[16:9] - 1920 x 1080 (1080HD)",
        "[16:9] - 2560 x 1440 (1440HD)",
        "[16:9] - 3840 x 2160 (4k)",
        "[16:9] - 7680 x 4320 (8k)",
        
        "[4:3] - 640 × 480",
        "[4:3] - 800 × 600",
        "[4:3] - 960 × 720",
        "[4:3] - 1024 × 768",
        "[4:3] - 1280 × 960",
        "[4:3] - 1400 × 1050",
        "[4:3] - 1440 × 1080",
        "[4:3] - 1600 × 1200",
        "[4:3] - 1856 × 1392",
        "[4:3] - 1920 × 1440",
        "[4:3] - 2048 × 1536",
        
        "[16:10] - 1280 × 800",
        "[16:10] - 1440 × 900",
        "[16:10] - 1680 × 1050",
        "[16:10] - 1920 × 1200",
        "[16:10] - 2560 × 1600"
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
    
    
    var videoFrameRateSelectMenuOptions = ["1", "2", "5", "10", "15", "20", "24", "29.97", "30", "60", "120", "240", "420"]
    
    var frameRates = [1, 2, 5, 10, 15, 20, 24, 29.97, 30, 60, 120, 240, 320, 420]
    
    
}
