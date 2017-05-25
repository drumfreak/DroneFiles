//
//  ScreenshotSettingsController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa

class ScreenShotSettingsViewController: NSViewController {
    
    @IBOutlet var sequenceNameTextField: ThemeLabelTextField!
    
    @IBOutlet var screenshotFolderLabel: ThemeLabel!
    
    @IBOutlet var screenshotPreviewCheckbox: ThemeCheckbox!
    
    @IBOutlet var screenshotTypeJPGCheckbox: ThemeCheckbox!
    
    @IBOutlet var screenshotTypePNGCheckbox: ThemeCheckbox!
    
    @IBOutlet var screeshotBurstCheckbox: ThemeCheckbox!
    
    @IBOutlet var shutterSoundCheckbox: ThemeCheckbox!
    
    @IBOutlet var preserveNameCheckbox: ThemeCheckbox!
    
    @IBOutlet var preserveDateCheckbox: ThemeCheckbox!
    
    @IBOutlet var preserveLocationCheckbox: ThemeCheckbox!
    
    @IBOutlet var numShotSBeforeTextField: NSTextField!
    
    @IBOutlet var numShotsAfterTextField: NSTextField!
    
    @IBOutlet var frameIntervalSlider: NSSlider!
    
    @IBOutlet var frameIntervalLabel: ThemeLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupOptions()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        setupOptions()
    }
    
    
    func setupOptions() {
        DispatchQueue.main.async {
            if(self.appSettings.screenshotPreserveVideoName) {
                self.preserveNameCheckbox.state = 1
            } else {
                self.preserveNameCheckbox.state = 0
            }
            
            if(self.appSettings.screenshotPreserveVideoLocation) {
                self.preserveLocationCheckbox.state = 1
            } else {
                self.preserveLocationCheckbox.state = 0
            }
            
            if(self.appSettings.screenshotSound) {
                self.shutterSoundCheckbox.state = 1
            } else {
                self.shutterSoundCheckbox.state = 0
            }
            
            
            if(self.appSettings.screenShotBurstEnabled) {
                self.screeshotBurstCheckbox.state = 1
            } else {
                self.screeshotBurstCheckbox.state = 0
            }
            
            
            if(self.appSettings.screenshotPreview) {
                self.screenshotPreviewCheckbox.state = 1
            } else {
                self.screenshotPreviewCheckbox.state = 0
            }
            
            
            if(self.appSettings.screenshotPreserveVideoDate) {
                self.preserveDateCheckbox.state = 1
            } else {
                self.preserveDateCheckbox.state = 0
            }
            
            if(self.appSettings.screenshotTypeJPG) {
                self.screenshotTypeJPGCheckbox.state = 1
                self.screenshotTypePNGCheckbox.state = 0
                
            } else {
                self.screenshotTypePNGCheckbox.state = 1
                self.screenshotTypeJPGCheckbox.state = 0
            }
            
            if(self.appSettings.screenshotTypePNG) {
                self.screenshotTypePNGCheckbox.state = 1
                self.screenshotTypeJPGCheckbox.state = 0
            } else {
                self.screenshotTypeJPGCheckbox.state = 1
                self.screenshotTypePNGCheckbox.state = 0
            }
            
            
            if(self.appSettings.screenshotPreserveVideoName) {
                self.sequenceNameTextField.isEnabled = false
            } else {
                self.sequenceNameTextField.stringValue = self.appSettings.fileSequenceName
            }
            
            self.screenshotFolderLabel.stringValue = (URL(string: self.appSettings.screenShotFolder)?.lastPathComponent)!
            
            
            self.screenshotFolderLabel.stringValue = (URL(string: self.appSettings.screenShotFolder)?.lastPathComponent
                )!
            
            self.numShotSBeforeTextField.intValue = self.appSettings.screenshotFramesBefore
            
            self.numShotsAfterTextField.intValue = self.appSettings.screenshotFramesAfter
            
            self.frameIntervalLabel.doubleValue = self.appSettings.screenshotFramesInterval
        }
    }
    
    
    
    @IBAction func rateSliderChanged(_ sender: NSSlider) {
        // let slider = sender as! NSSlider
        print(sender.doubleValue)
        self.appDelegate.appSettings.screenshotFramesInterval = sender.doubleValue
        
        self.frameIntervalLabel.doubleValue = sender.doubleValue
    }
    
    
    @IBAction func setInterval(_ sender: NSTextField) {
        // let slider = sender as! NSSlider
        print(sender.doubleValue)
        
        self.frameIntervalSlider.doubleValue = sender.doubleValue
        
        self.appDelegate.appSettings.screenshotFramesInterval = sender.doubleValue
        
        // self.frameIntervalLabel.doubleValue = sender.doubleValue
        
    }
    
    
    
    
    
    
    @IBAction func saveSettings(_ sender: AnyObject?) {
        
        if(self.screeshotBurstCheckbox.state == 0) {
            self.appDelegate.appSettings.screenShotBurstEnabled = false
        } else {
            self.appDelegate.appSettings.screenShotBurstEnabled = true
        }
        
        if(self.shutterSoundCheckbox.state == 0) {
            self.appDelegate.appSettings.screenshotSound = false
        } else {
            self.appDelegate.appSettings.screenshotSound = true
        }
        
        if(self.screenshotPreviewCheckbox.state == 0) {
            self.appDelegate.appSettings.screenshotPreview = false
        } else {
            self.appDelegate.appSettings.screenshotPreview = true
        }
        
        if(self.preserveDateCheckbox.state == 0) {
            self.appDelegate.appSettings.screenshotPreserveVideoDate = false
        } else {
            self.appDelegate.appSettings.screenshotPreserveVideoDate = true
        }
        
        
        if(self.preserveLocationCheckbox.state == 0) {
            self.appDelegate.appSettings.screenshotPreserveVideoLocation = false
        } else {
            self.appDelegate.appSettings.screenshotPreserveVideoLocation = true
        }
        
        if(self.preserveNameCheckbox.state == 0) {
            self.appDelegate.appSettings.screenshotPreserveVideoName = false
        } else {
            self.appDelegate.appSettings.screenshotPreserveVideoName = true
        }
        
        if(self.screenshotTypeJPGCheckbox.state == 0) {
            self.appDelegate.appSettings.screenshotTypeJPG = false
            self.appDelegate.appSettings.screenshotTypePNG = false
        } else {
            self.appDelegate.appSettings.screenshotTypeJPG = true
            self.appDelegate.appSettings.screenshotTypePNG = false
            
        }
        
        if(self.screenshotTypePNGCheckbox.state == 0) {
            self.appDelegate.appSettings.screenshotTypePNG = false
            self.appDelegate.appSettings.screenshotTypeJPG = true
        } else {
            self.appDelegate.appSettings.screenshotTypePNG = true
            self.appDelegate.appSettings.screenshotTypeJPG = false
        }
        
        self.appDelegate.appSettings.screenshotFramesBefore = self.numShotSBeforeTextField.intValue
        
        self.appDelegate.appSettings.screenshotFramesAfter = self.numShotsAfterTextField.intValue
        
        
        
        self.appDelegate.videoPlayerControlsController?.setupControls()
        self.appDelegate.saveProject()
        
        self.dismiss(nil)
        
        
        
    }
    
    
    
    
}
