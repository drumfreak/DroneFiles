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
    
    var sourceFolder = "file:///Volumes/DroneStick1/DCIM/100MEDIA/"
    var fileSequenceName = ""
    var fileSequenceNameTag = ""
    var projectDirectory = ""
    var outputDirectory = ""
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
    var appBackgroundColor = NSColor.init(patternImage: NSImage(named: "darkbackground-3.jpg")!)

    var appViewBackgroundColor = NSColor.init(patternImage: NSImage(named: "darkbackground-2.jpg")!)
    
    var themeViewDarkBox1 = NSColor.init(patternImage: NSImage(named: "darkbackground-2.jpg")!)
    
    var patternColor = NSColor.init(patternImage: NSImage(named: "darkbackground.png")!)
    
    var textLabelColor = NSColor.gray
    
    
}
