//
//  ThemeTables.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/17/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//
import Foundation
import Cocoa

public class ThemeTableRowView: NSTableRowView {
    
    override public func drawSelection(in dirtyRect: NSRect) {
        
        // Swift.print("ThemeTableRowView HEY (self.selectionHighlightStyle)")
        
        if self.selectionHighlightStyle != .none {
            
            
            //
            //            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
            //            NSColor(calibratedWhite: 0.65, alpha: 1).setStroke()
            //            NSColor(calibratedWhite: 0.82, alpha: 1).setFill()
            //            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
            //            selectionPath.fill()
            //            selectionPath.stroke()
            
            
        }
    }
}

public class ThemeTableViewCell: NSTableCellView {
    
    //override to change background color on highlight
    override public var backgroundStyle:NSBackgroundStyle{
        //check value when the style was setted
        didSet{
            
            self.wantsLayer = true
            
            // DO NOT CHANGE THE FUCKING COLOR!! DO IT TO THE ROW
            
            self.textField?.textColor = self.appSettings.textLabelColor
            
        }
    }
}


public class ThemeTableHeaderView : NSTableHeaderView {
    
    // this pretty much creates alternating row colors..
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        // Swift.print("Table HEader View")
        self.wantsLayer = true
        self.layer?.backgroundColor = self.appSettings.tableHeaderRowBackground.cgColor
        
    }
    
}



public class ThemeTableHeaderCell: NSTableHeaderCell {
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // self.wantsLayer = true
        // Swift.print("tableview cell Init")
        self.backgroundColor = self.appSettings.tableRowActiveBackGroundColor
        
        //self.layer?.backgroundColor = self.appSettings.tableViewBackgroundColor.cgColor
    }
    
    
    override init(textCell: String) {
        super.init(textCell: textCell)
        self.textColor = self.appSettings.textLabelColor
        
        // self.font = NSFont.boldSystemFontOfSize(14)
    }
    
    override public func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        
        self.drawInterior(withFrame: cellFrame, in: controlView)
        
    }
    
    override public func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        let titleRect = self.titleRect(forBounds: cellFrame)
        self.attributedStringValue.draw(in: titleRect)
    }
    
}



public class ThemeTableView : NSTableView {
    
    // this pretty much creates alternating row colors..
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.wantsLayer = true
        // Swift.print("SplitView Init")
        
        self.layer?.backgroundColor = self.appSettings.tableViewBackgroundColor.cgColor
    }
    
    private func
        alternateBackgroundColor() -> NSColor? {
        return self.appSettings.tableViewAlternatingRowColor // Return any color you like
    }
    
    public override func
        drawBackground(inClipRect clipRect: NSRect) {
        
        if alternateBackgroundColor() == nil {
            // If we didn't set the alternate colour, fall back to the default behaviour
            super.drawBackground(inClipRect: clipRect)
        } else {
            // Fill in the background colour
            self.backgroundColor.set()
            NSRectFill(clipRect)
            
            // Check if we should be drawing alternating coloured rows
            if usesAlternatingRowBackgroundColors {
                // Set the alternating background colour
                alternateBackgroundColor()!.set()
                
                // Go through all of the intersected rows and draw their rects
                var checkRect = bounds
                checkRect.origin.y = clipRect.origin.y
                checkRect.size.height = clipRect.size.height
                let rowsToDraw = rows(in: checkRect)
                var curRow = rowsToDraw.location
                repeat {
                    if curRow % 2 != 0 {
                        // This is an alternate row
                        var rowRect = rect(ofRow: curRow)
                        rowRect.origin.x = clipRect.origin.x
                        rowRect.size.width = clipRect.size.width
                        NSRectFill(rowRect)
                    }
                    
                    curRow += 1
                } while curRow < rowsToDraw.location + rowsToDraw.length
                
                // Figure out the height of "off the table" rows
                var thisRowHeight = rowHeight
                if gridStyleMask.contains(NSTableViewGridLineStyle.solidHorizontalGridLineMask)
                    || gridStyleMask.contains(NSTableViewGridLineStyle.dashedHorizontalGridLineMask) {
                    thisRowHeight += 2.0 // Compensate for a grid
                }
                
                // Draw fake rows below the table's last row
                var virtualRowOrigin = 0.0 as CGFloat
                var virtualRowNumber = numberOfRows
                if numberOfRows > 0 {
                    let finalRect = rect(ofRow: numberOfRows-1)
                    virtualRowOrigin = finalRect.origin.y + finalRect.size.height
                }
                repeat {
                    if virtualRowNumber % 2 != 0 {
                        // This is an alternate row
                        let virtualRowRect = NSRect(x: clipRect.origin.x, y: virtualRowOrigin, width: clipRect.size.width, height: thisRowHeight)
                        NSRectFill(virtualRowRect)
                    }
                    
                    virtualRowNumber += 1
                    virtualRowOrigin += thisRowHeight
                } while virtualRowOrigin < clipRect.origin.y + clipRect.size.height
                
                // Draw fake rows above the table's first row
                virtualRowOrigin = -1 * thisRowHeight
                virtualRowNumber = -1
                repeat {
                    if abs(virtualRowNumber) % 2 != 0 {
                        // This is an alternate row
                        let virtualRowRect = NSRect(x: clipRect.origin.x, y: virtualRowOrigin, width: clipRect.size.width, height: thisRowHeight)
                        NSRectFill(virtualRowRect)
                    }
                    
                    virtualRowNumber -= 1
                    virtualRowOrigin -= thisRowHeight
                } while virtualRowOrigin + thisRowHeight > clipRect.origin.y
            }
        }
    }
}
