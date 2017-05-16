//
//  ThemeView.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/15/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation

import AppKit

class ThemeViewDark: NSView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.wantsLayer = true

        self.layer?.backgroundColor = self.appDelegate.appSettings.appViewBackgroundColor.cgColor
    }
}


class ThemeViewDarkBox1: NSBox {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.wantsLayer = true
        Swift.print("DarkBox Init")
        
        self.fillColor = self.appDelegate.appSettings.themeViewDarkBox1
    }
}


class ThemeSplitViewMain: NSSplitView {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.wantsLayer = true
        Swift.print("SplitView Init")
        
        self.layer?.backgroundColor = self.appDelegate.appSettings.appBackgroundColor.cgColor
        
        
    }
}
