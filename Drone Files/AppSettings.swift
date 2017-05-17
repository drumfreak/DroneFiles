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

    
    var sourceFolder = "file:///Volumes/DroneStick1/DCIM/100MEDIA/"
    var fileSequenceName = ""
    var fileSequenceNameTag = ""
    var projectDirectory = ""
    
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

    
    
    var textLabelColor = NSColor.gray
    
    
}
