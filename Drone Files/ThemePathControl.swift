//
//  ThemePathControl.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/15/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//


import Foundation
import AppKit

class ThemePathControl: NSPathControl {
    
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)!
        
        Swift.print("This initted")
        
        //        let paragraph = NSMutableParagraphStyle()
        //        paragraph.alignment = .left
        //
        //        let myAttribute = [NSForegroundColorAttributeName: NSColor.lightGray,
        //                           NSParagraphStyleAttributeName: paragraph
        //        ]
        //
        //
        //        let myAttrString = NSAttributedString(string: (self.cell?.title)!, attributes: myAttribute)
        //
        //        self.cell?.attributedStringValue = myAttrString
               let foo = self.pathComponentCells()
//        
//        foo.first?.changeColor(NSColor.lightGray)
        
        foo.first?.textColor = NSColor.lightGray
        
        
    }
}


class ThemePathControlCell: NSPathCell {
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        Swift.print("This cell initted")
       //  self.setT
        // self.title = "Fuck"
        
        // let myAttribute = [NSForegroundColorAttributeName: NSColor.lightGray
       //  ]
//
//        
        // let myAttrString = NSAttributedString(string: "foo", attributes: myAttribute)

        // self.cell. attributedStringValue = myAttrString
        
    }
}
