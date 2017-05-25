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
    
    
    var secondDisplayIsOpen = false {
        didSet {
            
        }
    }
    
    
    var mediaBinSlideshowRunning = false {
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
    
    var screenshotFramesInterval = Double(2.0) {
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
    
    var mediaBinTimerInterval = Double(2.0) {
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
    
    var appViewBackgroundColor = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
    var themeViewDarkBox1 = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
    var patternColor = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
    var tableViewBackgroundColor = NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
    // normal row
    var tableRowBackGroundColor =  NSColor.init(patternImage: NSImage(named: "darkbrownbackground.png")!)
    
    // Alternate row
    var tableViewAlternatingRowColor = NSColor.init(patternImage: NSImage(named: "tablerow-black.png")!)
    
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
}
