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
    
    
    var zoomFactor =  0.5
    var rotationAngle = 0.0
    var saveOptions: IKSaveOptions!
    var saveUrl: URL!
    var viewIsLoaded = false
    
    var zoomInFactor =  0.02
    var zoomOutFactor = 0.02
    
    var isCropping = false
    
    
    //var imageProperties;
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Controls viewDidLoad")
        
        //self.imageView = self.appDelegate.imageEditorViewController?.imageView
        self.viewIsLoaded = true
        self.imageView = self.appDelegate.imageEditorViewController?.imageView
        self.appDelegate.imageEditorControlsController = self
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        print("Controls viewDidAppear")
        
        //        self.viewIsLoaded = true
        //        self.imageView = self.appDelegate.imageEditorViewController?.imageView
    }
    
    
    
    
    @IBAction func cropImage(_ sender: AnyObject) {
        print("Hey cropImage")
        if(self.isCropping) {
            self.imageView.currentToolMode = IKToolModeNone
            self.isCropping = false
        } else {
            self.isCropping = true
            self.imageView.currentToolMode = IKToolModeCrop
        }
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
        
        let image1 = self.imageView.image().takeUnretainedValue() // This crashes?
        
        let dest = CGImageDestinationCreateWithURL(self.saveUrl! as CFURL, self.saveOptions.imageUTType! as CFString, 1, nil)
        
        
        if ((dest) != nil)
        {
            CGImageDestinationAddImage(dest!, image1, self.saveOptions.imageProperties! as CFDictionary)
            CGImageDestinationFinalize(dest!)
            
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
        }
    }
    
    @IBAction func cancelImage(_ sender: AnyObject) {
        print("Hey cancelImage")
    }
    
    @IBAction func resetImage(_ sender: AnyObject) {
        print("Hey resetImage")
        self.imageView.currentToolMode = IKToolModeNone
        // self.imageView.setRotationAngle(0.0, center: NSPoint(x: 0.0, y: 0.0))
        self.rotationAngle = 0.0
        self.imageRotated(by: 0)
        self.zoomFactor = 0.0
        self.imageView.zoomImageToFit(nil)
    }
    
    @IBAction func zoomIn(_ sender: AnyObject) {
        self.imageView.currentToolMode = IKToolModeMove
        self.zoomFactor = self.zoomFactor + self.zoomInFactor
        self.imageView.setImageZoomFactor(CGFloat(self.zoomFactor), center: NSPoint(x: CGFloat(0), y: CGFloat(self.imageView.imageSize().height / 3)))
    }
    
    @IBAction func zoomOut(_ sender: AnyObject) {
        self.zoomFactor = self.zoomFactor - self.zoomOutFactor
        self.imageView.setImageZoomFactor(CGFloat(self.zoomFactor), center: NSPoint(x: CGFloat(self.imageView.imageSize().width / 2), y: CGFloat(self.imageView.imageSize().height / 2)))
    }
    
    
    @IBAction func showEditControls(_ sender: AnyObject) {
        print(self.imageView.imageProperties())
        self.imageView.editable = !self.imageView.editable
    }
    
    
    @IBAction func rotateLeft(_ sender: AnyObject) {
        self.imageView.currentToolMode = IKToolModeRotate
        self.rotationAngle = self.rotationAngle - 0.1
        self.imageRotated(by: CGFloat(self.rotationAngle))
        self.imageView.currentToolMode = IKToolModeMove
        print("Setting Rotation to: \(self.rotationAngle)")
        
    }
    
    @IBAction func rotateRight(_ sender: AnyObject) {
        self.rotationAngle = self.rotationAngle + 0.1
        self.imageView.currentToolMode = IKToolModeRotate
        self.imageRotated(by: CGFloat(self.rotationAngle))
        self.imageView.currentToolMode = IKToolModeMove
        print("Setting Rotation to: \(self.rotationAngle)")
        
    }
    
    
    @IBAction func rotateLeft1(_ sender: AnyObject) {
        self.imageView.currentToolMode = IKToolModeRotate
        self.rotationAngle = self.rotationAngle - 1.0
        self.imageRotated(by: CGFloat(self.rotationAngle))
        self.imageView.currentToolMode = IKToolModeMove
        print("Setting Rotation to: \(self.rotationAngle)")
        
    }
    
    @IBAction func rotateRight1(_ sender: AnyObject) {
        self.rotationAngle = self.rotationAngle + 1.0
        self.imageView.currentToolMode = IKToolModeRotate
        self.imageRotated(by: CGFloat(self.rotationAngle))
        self.imageView.currentToolMode = IKToolModeMove
        print("Setting Rotation to: \(self.rotationAngle)")
        
    }
    
    
    @IBAction func rotateLeft90(_ sender: AnyObject) {
        self.imageView.currentToolMode = IKToolModeRotate
        self.rotationAngle = self.rotationAngle - 90.0
        self.imageRotated(by: CGFloat(self.rotationAngle))
        self.imageView.currentToolMode = IKToolModeMove
        self.imageView.zoomImageToFit(nil)
        print("Setting Rotation to: \(self.rotationAngle)")
        
    }
    
    @IBAction func rotateRight90(_ sender: AnyObject) {
        self.rotationAngle = self.rotationAngle + 90.0
        self.imageView.currentToolMode = IKToolModeRotate
        self.imageRotated(by: CGFloat(self.rotationAngle))
        self.imageView.currentToolMode = IKToolModeMove
        self.imageView.zoomImageToFit(nil)
        print("Setting Rotation to: \(self.rotationAngle)")
        
    }
    
    func imageRotated(by degrees: CGFloat){
        let angle = CGFloat(-(degrees / 180) * CGFloat(Double.pi))
        print("Setting Angle to: \(angle)")
        
        self.imageView.rotationAngle = angle
    }
    
    
    
    @IBAction func switchToolMode(_ sender: AnyObject) {
        
        // switch the tool mode...
        
        var newTool = Int(0)
        
        if(sender.isKind(of: NSSegmentedControl.self)) {
            newTool = sender.selectedSegment
        } else {
            newTool = sender.tag
        }
        
        switch newTool {
            case 0:
                self.imageView.currentToolMode = IKToolModeMove
            break
            case 1:
                self.imageView.currentToolMode = IKToolModeSelect
            break
            case 2:
                self.imageView.currentToolMode = IKToolModeCrop
            break
            case 3:
                self.imageView.currentToolMode = IKToolModeRotate
            break;
            case 4:
                self.imageView.currentToolMode = IKToolModeAnnotate
            break
            default:
            
            break
    
        }
    }
    
    
}
//
//extension NSImage {
//    func imageRotated(by degrees: CGFloat) -> NSImage {
//        let imageRotator = IKImageView()
//        var imageRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
//        let cgImage = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
//        imageRotator.setImage(cgImage, imageProperties: [:])
//        imageRotator.rotationAngle = CGFloat(-(degrees / 180) * CGFloat(M_PI))
//        let rotatedCGImage = imageRotator.image().takeUnretainedValue()
//        return NSImage(cgImage: rotatedCGImage, size: NSSize.zero)
//    }
//}
