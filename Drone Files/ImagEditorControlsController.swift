//
//  ImagEditorControlsController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/9/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//


import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz

class ImageEditorControllsController: NSViewController {
    
    
    var zoomInFactor =  1.414214
    var zoomOutFactor = 0.7071068
    var rotationAngle = 0.0
    var saveOptions: IKSaveOptions!
    var saveUrl: URL!
    
    @IBOutlet weak var imageEditorViewController: ImageEditorViewController!
    @IBOutlet var imageView: IKImageView!
    
    @IBOutlet var editImageLabel: NSTextField!
    
    @IBOutlet var rotateLeftButton: NSButton!
    
    @IBOutlet var rotateRightButton: NSButton!
    
    @IBOutlet var cropButton: NSButton!
    
    @IBOutlet var saveButton: NSButton!
    
    @IBOutlet var cancelButton: NSButton!
    
    @IBOutlet var zoomInButton: NSButton!
    
    @IBOutlet var zoomOutButton: NSButton!
    
    @IBOutlet var resetButton: NSButton!
    
    @IBOutlet var appearanceButton: NSButton!

    @IBOutlet var moveButton: NSButton!
    
    @IBAction func rotateLeft(_ sender: AnyObject) {
        print("Hey rotateLeft")
        self.imageView.currentToolMode = IKToolModeRotate
        self.rotationAngle = self.rotationAngle + 0.05
        
        self.imageView.setRotationAngle(CGFloat(self.rotationAngle), center: NSPoint(x: 0, y: 0))
    }
    
    @IBAction func rotateRight(_ sender: AnyObject) {
        print("Hey rotateRight")
        self.imageView.currentToolMode = IKToolModeRotate
        self.rotationAngle = self.rotationAngle - 0.05
        self.imageView.setRotationAngle(CGFloat(self.rotationAngle), center: NSPoint(x: 0, y: 0))
    }
    
    @IBAction func cropImage(_ sender: AnyObject) {
        print("Hey cropImage")
        self.imageView.currentToolMode = IKToolModeCrop
    }
    
    @IBAction func moveImage(_ sender: AnyObject) {
        print("Hey moveImage")
        self.imageView.currentToolMode = IKToolModeMove
    }
    
    
    @IBAction func saveImage(_ sender: AnyObject) {
        print("Hey saveImage")
        // self.imageView.saveOptions(IKSaveOptions!, shouldShowUTType: false)
        
        let savePanel = NSSavePanel()
        savePanel.canSelectHiddenExtension = true
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = true
        
        let filePath = self.appDelegate.imageEditorViewController?.imageUrl.deletingLastPathComponent()
        
        
        let fileNameNoExtension = self.appDelegate.imageEditorViewController?.imageUrl?.deletingPathExtension()
        
        var fileName = fileNameNoExtension?.lastPathComponent
        
        fileName = fileName! + " - Edited"
        
        savePanel.nameFieldStringValue = fileName!
        savePanel.directoryURL = filePath
        
        
        let imageUrl = NSURL.init(string: (self.appDelegate.imageEditorViewController?.imageUrl.absoluteString)!)
        
        let image = CGImageSourceCreateWithURL(imageUrl!, nil)
        
        let imageUTType = CGImageSourceGetType(image!)
        
        self.saveOptions = IKSaveOptions.init(imageProperties: self.imageView.imageProperties(), imageUTType: imageUTType! as String)
        
        self.saveOptions?.addAccessoryView(to: savePanel)
        
        
        // [savePanel setNameFieldStringValue:[[_window representedFilename] lastPathComponent]];
        
        
        savePanel.begin { result in
            if result == NSFileHandlingPanelOKButton {
                guard let url = savePanel.url else { return }
                print("SAVE PANEL URL: \(url)")
                
                self.saveUrl = url
                self.saveFile()
            }
        }
    }
    
    func saveFile() {
        
        // get the current image from the image view
       //  let image = self.appDelegate.imageEditorViewController.imageView.image as! CGImage
        
        let image1 = self.imageView.image().takeUnretainedValue()
        
        // print(image1 ?? <#default value#>)
        
        // let image2 = image1
        
       // if (image)
       // {
            // use ImageIO to save the image in the user specified format
   
            let dest = CGImageDestinationCreateWithURL(self.saveUrl! as CFURL, self.saveOptions.imageUTType! as CFString, 1, nil)
            
        
            if ((dest) != nil)
            {
                CGImageDestinationAddImage(dest!, image1, self.saveOptions.imageProperties! as CFDictionary)
                CGImageDestinationFinalize(dest!)
        
               // CGImageDestinationAddImage(dest, image, (__bridge CFDictionaryRef)[_saveOptions imageProperties]);
                //CGImageDestinationFinalize(dest);
                // CFRelease(dest);
            }
       
        
    }
    
    @IBAction func cancelImage(_ sender: AnyObject) {
        print("Hey cancelImage")
        
    }
    
    @IBAction func resetImage(_ sender: AnyObject) {
        print("Hey resetImage")
        self.imageView.currentToolMode = IKToolModeNone
        self.imageView.setRotationAngle(0.0, center: NSPoint(x: 0.0, y: 0.0))
        
        self.imageView.zoomImageToFit(nil)
        
    }
    
    @IBAction func zoomIn(_ sender: AnyObject) {
        print("Hey zoomIn")
        self.imageView.setImageZoomFactor(CGFloat(1.1), center: NSPoint(x: CGFloat(0), y: CGFloat(0)))
    }
    
    @IBAction func zoomOut(_ sender: AnyObject) {
        print("Hey zoomOut")
        
        self.imageView.setImageZoomFactor(CGFloat(1.0), center: NSPoint(x: CGFloat(0), y: CGFloat(0)))
    }
    
    
    @IBAction func showEditControls(_ sender: AnyObject) {
        print("Hey showEditControls")
        
        print(self.imageView.imageProperties())
        
        
        self.imageView.editable = !self.imageView.editable
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView = self.appDelegate.imageEditorViewController?.imageView
    }
    
    
    
    
}
