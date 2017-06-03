//
//  ScreenShotCollectionViewItem.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class ScreenShotCollectionViewItem: NSCollectionViewItem {
    
    @IBOutlet weak var playerButton: NSButton!
    
    // 1
    var imageFile: ImageFile? {
        didSet {
            guard isViewLoaded else { return }
            
            DispatchQueue.main.async {
                
                if let imageFile = self.imageFile {
                    
                    
                    self.imageView?.image = imageFile.thumbnail
                    self.textField?.stringValue = imageFile.fileName
                    
                    if(imageFile.videoUrl != nil) {
                        if(imageFile.asset.isPlayable) {
                            self.playerButton?.isHidden = false
                            self.playerButton?.isEnabled = true
                        }
                    } else {
                        self.playerButton?.isHidden = true
                    }
                
                } else {
                
                    self.imageView?.image = nil
                    self.textField?.stringValue = ""
                
                
                }
            }
        }
    }
    
    // 2
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            
            self.view.wantsLayer = true
            self.view.layer?.backgroundColor = self.appSettings.imageThumbnailHolder.cgColor
            
            self.view.layer?.borderWidth = 0.0
            self.view.layer?.cornerRadius = 8.0
            // print("Fuck yeah...")
            // 2
            self.view.layer?.borderColor = self.appSettings.tableRowActiveBackGroundColor.cgColor
        }
    }
    
    func setButtonVisible(_ visible: Bool) {
        self.playerButton?.isHidden = visible
    }
    
    func setHighlight(selected: Bool) {
        view.layer?.borderWidth = selected ? 5.0 : 0.0
    }
}
