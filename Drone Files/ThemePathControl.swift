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
        
        // Swift.print("This initted")
        
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


class ThemePathComponentCell: NSPathComponentCell {
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        Swift.print("This NSPathComponentCell initted")
        
        self.textColor = NSColor.lightGray
        
        
        
//            - (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//                NSImage *background = [NSImage imageNamed:@"ITPathbar-fill"];
//                [background drawInRect:cellFrame fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0 respectFlipped:YES hints:NO];
//                
//                [super drawWithFrame:cellFrame inView:controlView];
        }
    
}

class ThemePathControlCell: NSPathCell {
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        // Swift.print("This cell initted")
        Swift.print("This cell initted")

        self.pathComponentCells.forEach({m in
            
            Swift.print("CELLLL  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

            m.textColor = NSColor.lightGray
        })
        
        
    }
}
