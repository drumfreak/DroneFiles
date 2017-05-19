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
            view.layer?.backgroundColor = self.appSettings.imageThumbnailHolder.cgColor
            
            view.layer?.borderWidth = 0.0
            // 2
            view.layer?.borderColor = self.appSettings.tableRowActiveBackGroundColor.cgColor
        }
    
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 5.0 : 0.0
    }
}
