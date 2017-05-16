//
//  ThemeLabel.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/15/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//


import Foundation
import AppKit

class ThemeLabel: NSTextField {
    
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        self.textColor = self.appDelegate.appSettings.textLabelColor
        
    }
}

