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
    
    var blockScreenShotTabSwitch = true
    
    var mediaBinUrls = [URL]() {
        didSet {
            print(mediaBinUrls)
            
            let data = NSKeyedArchiver.archivedData(withRootObject: mediaBinUrls)
            
            userDefaults.setValue(data, forKey: "mediaBinUrls")

//            if let output = mediaBinUrls {
//                print("Fuck yeah set the media array")
//
//                print("\(String(describing: output))")
//                userDefaults.setValue(output, forKey: "mediaBinUrls")
//            }
        }
    }
    
    var outputDirectory: String! {
        didSet {
            if let output = outputDirectory {
                // defaults.value(forKey: "outputDirectory") as! String
                userDefaults.setValue(output, forKey: "outputDirectory")
            }
        }
    }
    
    
    var lastFolderOpened: String! {
        didSet {
            if let output = lastFolderOpened {
                // defaults.value(forKey: "outputDirectory") as! String
                print("lastFolderOpened \(lastFolderOpened)")
                
                userDefaults.setValue(output, forKey: "lastFolderOpened")
            }
        }
    }
    

    var lastFileOpened: String! {
        didSet {
            if let output = lastFileOpened {
                // defaults.value(forKey: "outputDirectory") as! String
                userDefaults.setValue(output, forKey: "lastFileOpened")
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
    

    // Screenshots
    
    var screenShotBurstEnabled = Bool(true) {
        didSet {
            userDefaults.setValue(screenShotBurstEnabled, forKey: "screenShotBurstEnabled")
        }
    }
    
    var screenshotSound = Bool(true) {
        didSet {
            userDefaults.setValue(screenshotSound, forKey: "screenshotSound")
        }
    }

    
    var screenshotPreview = Bool(false){
        didSet {
            userDefaults.setValue(screenshotPreview, forKey: "screenshotPreview")
        }
    }
    
    var screenshotPreserveVideoDate = Bool(true) {
        didSet {
            userDefaults.setValue(screenshotPreserveVideoDate, forKey: "screenshotPreserveVideoDate")
        }
    }
    

    var screenshotPreserveVideoLocation = Bool(false) {
        didSet {
            userDefaults.setValue(screenshotPreserveVideoLocation, forKey: "screenshotPreserveVideoLocation")
        }
    }
    
    var screenshotPreserveVideoName = Bool(true) {
        didSet {
            userDefaults.setValue(screenshotPreserveVideoName, forKey: "screenshotPreserveVideoName")
        }
    }
    
    
    var screenshotFramesBefore = Int32(5) {
        didSet {
            userDefaults.setValue(screenshotFramesBefore, forKey: "screenshotFramesBefore")
        }
    }

    var screenshotFramesAfter = Int32(5) {
        didSet {
            userDefaults.setValue(screenshotFramesAfter, forKey: "screenshotFramesAfter")
        }
    }
    
    var screenshotFramesInterval = Double(0.1) {
        didSet {
            userDefaults.setValue(screenshotFramesInterval, forKey: "screenshotFramesInterval")
        }
    }
    
    
    var screenshotTypeJPG = Bool(true) {
        didSet {
            userDefaults.setValue(screenshotTypeJPG, forKey: "screenshotTypeJPG")
        }
    }
    
    var screenshotTypePNG = Bool(false) {
        didSet {
            userDefaults.setValue(screenshotTypePNG, forKey: "screenshotTypePNG")
        }
    }
    
    
    // Media Bin Stuff
    
    var mediaBinTimerInterval = Double(0.2) {
        didSet {
            userDefaults.setValue(mediaBinTimerInterval, forKey: "mediaBinTimerInterval")
        }
    }
    

    
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
    var messageBoxBackground =  NSColor.init(patternImage: NSImage(named: "messagewindow.png")!)

    
    var textLabelColor = NSColor.gray
    
    // Image thumbnail for collection View Backgrounds
    // tableHeaderRow
    var imageThumbnailHolder =  NSColor.init(patternImage: NSImage(named: "messagewindow.png")!)

    
    
}
