//
//  ScreenShotCollectionViewItem.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class ScreenShotCollectionViewItem: NSCollectionViewItem {
        
        // 1
        var imageFile: ImageFile? {
            didSet {
                guard isViewLoaded else { return }
                if let imageFile = imageFile {
                    imageView?.image = imageFile.thumbnail
                    textField?.stringValue = imageFile.fileName
                } else {
                    imageView?.image = nil
                    textField?.stringValue = ""
                }
            }
        }
        
        // 2
        override func viewDidLoad() {
            super.viewDidLoad()
            view.wantsLayer = true
            view.layer?.backgroundColor = NSColor.lightGray.cgColor
        }
}
