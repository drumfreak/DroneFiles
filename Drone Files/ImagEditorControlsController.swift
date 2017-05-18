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
import QuartzCore

class ImageEditorControllsController: NSViewController {

    var zoomFactor =  0.0
    var rotationAngle = 0.0
    var saveUrl: URL!
    var viewIsLoaded = false
    
    var zoomInFactor =  0.02
    var zoomOutFactor = 0.02
    
    var isCropping = false
    
    var imageProperties: NSDictionary = Dictionary<String, String>() as NSDictionary
    var imageUTType: String = ""
    var saveOptions: IKSaveOptions = IKSaveOptions()
    
    
    //var imageProperties;
    @IBOutlet var rotationSlider: NSSlider!
    @IBOutlet var zoomSlider: NSSlider!
    @IBOutlet var zoomVerticalSlider: NSSlider!

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
    
    @IBOutlet var controlsBox: NSView!

    
    @IBOutlet weak var nowPlayingFile: NSTextField!
    
    var nowPlayingURLString: String!
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// print("Controls viewDidLoad")
        
        //self.imageView = self.appDelegate.imageEditorViewController?.imageView
        self.viewIsLoaded = true
        self.imageView = self.appDelegate.imageEditorViewController?.imageView
        self.appDelegate.imageEditorControlsController = self
        
        
        //  self.appDelegate.imageEditorViewController?.imageView.delegate = self
        //        [_imageView zoomImageToFit: self];
        // self.filterPanel?.filterBrowserView(options: [:])
        
        // self.filterPanel?.beginSheet(options: [:], modalFor: self.appDelegate.window, modalDelegate: Any!(), didEnd:Selector(("switchToolMode:")), contextInfo: nil)
    
        self.controlsBox.isHidden = true


    }
    

    
    override func viewDidAppear() {
        super.viewDidAppear()
        
    }
    

    @IBAction func showFilterWindow(_ sender: AnyObject) {
        
        let filterPanel = IKFilterBrowserPanel()
        
        filterPanel.beginSheet(options: [:], modalFor: self.appDelegate.window, modalDelegate: self, didEnd: #selector(ImageEditorControllsController.modalEnded), contextInfo: nil)        
        
        let nc = NotificationCenter.default
        
        nc.addObserver(self, selector: #selector(self.catchNotification(notification:)), name: .IKFilterBrowserFilterSelected, object: nil)

        nc.addObserver(self, selector: #selector(self.catchNotification(notification:)), name: .IKFilterBrowserFilterDoubleClick, object: nil)
        
        nc.addObserver(self, selector: #selector(self.catchNotification(notification:)), name: .IKFilterBrowserWillPreviewFilter, object: nil)

    }
    
    
    @IBAction func toggleEditorControls(_ sender: AnyObject) {
        self.controlsBox.isHidden = !self.controlsBox.isHidden
    }

    
    func catchNotification(notification:Notification) -> Void {
        print(notification)
        //print("Catch notification")
    }
    
    func modalEnded() {
        print("MODAL ENDED");
    }

    
    @IBAction func cropImage(_ sender: AnyObject) {
        print("Hey cropImage")
        if(self.isCropping) {
             self.appDelegate.imageEditorViewController?.imageView.crop(self)
             self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(nil)
            self.rotationAngle = 0.0
            self.imageRotated(by: CGFloat(self.rotationAngle))
             self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeNone
            self.isCropping = false
        } else {
            self.isCropping = true
             self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeCrop
        }
    }
    
    @IBAction func moveImage(_ sender: AnyObject) {
        print("Hey moveImage")
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
    }
    
    @IBAction func rotationSliderChanged(_ sender: NSSlider) {
       // let slider = sender as! NSSlider
        print(sender.doubleValue)
        self.rotationAngle = sender.doubleValue
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeRotate
        self.imageRotated(by: CGFloat(self.rotationAngle))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
         self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(nil)
        print("Setting Rotation to: \(self.rotationAngle)")
    }
    
    
    @IBAction func zoomSliderChanged(_ sender: NSSlider) {
        // let slider = sender as! NSSlider
        print(sender.doubleValue)
        self.zoomFactor = sender.doubleValue
        
         self.appDelegate.imageEditorViewController?.imageView.setImageZoomFactor(CGFloat(self.zoomFactor), center: NSPoint(x: CGFloat( (self.appDelegate.imageEditorViewController?.imageView.imageSize().width)! / 2), y: CGFloat( (self.appDelegate.imageEditorViewController?.imageView.imageSize().height)! / 2)))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
        self.zoomVerticalSlider.doubleValue = self.zoomFactor
        //  self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(nil)
        print("Setting Rotation to: \(self.rotationAngle)")
    }
    
    @IBAction func zoomVerticalSliderChanged(_ sender: NSSlider) {
        // let slider = sender as! NSSlider
        print(sender.doubleValue)
        self.zoomFactor = sender.doubleValue
        
         self.appDelegate.imageEditorViewController?.imageView.setImageZoomFactor(CGFloat(self.zoomFactor), center: NSPoint(x: CGFloat( (self.appDelegate.imageEditorViewController?.imageView.imageSize().width)! / 2), y: CGFloat( (self.appDelegate.imageEditorViewController?.imageView.imageSize().height)! / 2)))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
        self.zoomSlider.doubleValue = self.zoomFactor

        //  self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(nil)
        print("Setting Rotation to: \(self.rotationAngle)")
    }

    
    @IBAction func saveImage(_ sender: AnyObject) {
        print("Hey saveImage")
        //  self.appDelegate.imageEditorViewController?.imageView.saveOptions(IKSaveOptions!, shouldShowUTType: false)
        
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
        
        self.saveOptions = IKSaveOptions.init(imageProperties:  self.appDelegate.imageEditorViewController?.imageView.imageProperties(), imageUTType: imageUTType! as String)
        
        self.saveOptions.addAccessoryView(to: savePanel)
        
        savePanel.begin { result in
            if result == NSFileHandlingPanelOKButton {
                guard let url = savePanel.url else { return }
                //print("SAVE PANEL URL: \(url)")
                
                
                // self.appDelegate.fileBrowserViewController?.loadImage(_url: url)
                
                self.saveUrl = url
                self.saveFile()
            }
        }
    }
    
    
    func saveFile() {
        
        let image1 = self.appDelegate.imageEditorViewController?.imageView!.image()!.takeUnretainedValue() // This crashes?
        
        let dest = CGImageDestinationCreateWithURL(self.saveUrl! as CFURL, self.saveOptions.imageUTType! as CFString, 1, nil)
        
        
        if ((dest) != nil)
        {
            CGImageDestinationAddImage(dest!, image1!, self.saveOptions.imageProperties! as CFDictionary)
            CGImageDestinationFinalize(dest!)
            
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: self.saveUrl.absoluteString)
            self.appDelegate.imageEditorViewController?.loadImage(_url: self.saveUrl!)

        }
    }
    
    @IBAction func cancelImage(_ sender: AnyObject) {
        //print("Hey cancelImage")
    }
    
    @IBAction func resetImage(_ sender: AnyObject) {
        // print("Hey resetImage")
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeNone
        //  self.appDelegate.imageEditorViewController?.imageView.setRotationAngle(0.0, center: NSPoint(x: 0.0, y: 0.0))
        self.rotationAngle = 0.0
        self.imageRotated(by: 0)
        self.zoomFactor = 0.0
         self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(nil)
    }
    
    @IBAction func zoomIn(_ sender: AnyObject) {
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
        self.zoomFactor = self.zoomFactor + self.zoomInFactor
         self.appDelegate.imageEditorViewController?.imageView.setImageZoomFactor(CGFloat(self.zoomFactor), center: NSPoint(x: CGFloat(0), y: CGFloat( (self.appDelegate.imageEditorViewController?.imageView.imageSize().height)! / 3)))
        
        
        self.zoomSlider.doubleValue = self.zoomFactor

    }
    
    @IBAction func zoomOut(_ sender: AnyObject) {
        self.zoomFactor = self.zoomFactor - self.zoomOutFactor
         self.appDelegate.imageEditorViewController?.imageView.setImageZoomFactor(CGFloat(self.zoomFactor), center: NSPoint(x: CGFloat( (self.appDelegate.imageEditorViewController?.imageView.imageSize().width)! / 2), y: CGFloat( (self.appDelegate.imageEditorViewController?.imageView.imageSize().height)! / 2)))
        self.zoomSlider.doubleValue = self.zoomFactor
    }
    
    
    @IBAction func showEditControls(_ sender: AnyObject) {
        //print(self.appDelegate.imageEditorViewController?.imageView.imageProperties()! as Any)
         self.appDelegate.imageEditorViewController?.imageView.editable = !(self.appDelegate.imageEditorViewController?.imageView.editable)!
    }
    
    
    @IBAction func rotateLeft(_ sender: AnyObject) {
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeRotate
        self.rotationAngle = self.rotationAngle - 0.1
        self.imageRotated(by: CGFloat(self.rotationAngle))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
        print("Setting Rotation to: \(self.rotationAngle)")
        
    }
    
    @IBAction func rotateRight(_ sender: AnyObject) {
        self.rotationAngle = self.rotationAngle + 0.1
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeRotate
        self.imageRotated(by: CGFloat(self.rotationAngle))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
        print("Setting Rotation to: \(self.rotationAngle)")
    }
    
    @IBAction func rotateLeft1(_ sender: AnyObject) {
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeRotate
        self.rotationAngle = self.rotationAngle - 1.0
        self.imageRotated(by: CGFloat(self.rotationAngle))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
        print("Setting Rotation to: \(self.rotationAngle)")
    }
    
    @IBAction func rotateRight1(_ sender: AnyObject) {
        self.rotationAngle = self.rotationAngle + 1.0
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeRotate
        self.imageRotated(by: CGFloat(self.rotationAngle))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
        print("Setting Rotation to: \(self.rotationAngle)")
    }
    
    
    @IBAction func rotateLeft90(_ sender: AnyObject) {
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeRotate
        self.rotationAngle = self.rotationAngle - 90.0
        self.imageRotated(by: CGFloat(self.rotationAngle))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
         self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(nil)
        print("Setting Rotation to: \(self.rotationAngle)")
    }
    
    @IBAction func rotateRight90(_ sender: AnyObject) {
        self.rotationAngle = self.rotationAngle + 90.0
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeRotate
        self.imageRotated(by: CGFloat(self.rotationAngle))
         self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
         self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(nil)
        //print("Setting Rotation to: \(self.rotationAngle)")
    }
    
    func imageRotated(by degrees: CGFloat){
        let angle = CGFloat(-(degrees / 180) * CGFloat(Double.pi))
        //print("Setting Angle to: \(angle)")
         self.appDelegate.imageEditorViewController?.imageView.rotationAngle = angle
        self.rotationSlider.doubleValue = self.rotationAngle
    }
    
    
    
    @IBAction func switchToolMode(sender: AnyObject) {
        
        // switch the tool mode...
        
        var newTool = Int(0)
        
        if(sender.isKind(of: NSSegmentedControl.self)) {
            newTool = (sender.selectedSegment)!
        } else {
            newTool = (sender.tag)!
        }
        
       // print("SWITCHING TO NEW TOOL \(newTool)")
            
        switch newTool {
            case 0:
                 self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeMove
            break
            case 1:
                 self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeSelect
            break
            case 2:
                 self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeCrop
            break
            case 3:
                 self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeRotate
            break;
            case 4:
                 self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeAnnotate
            break
            default:
                 self.appDelegate.imageEditorViewController?.imageView.currentToolMode = IKToolModeNone

            break
    
        }
    }
    
    
    func windowDidResize (notification: NSNotification?) {
         self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(self)
    }
    
    
    /* IBActions. */
    @IBAction func doZoom (sender: AnyObject) {
        var zoom = Int()
        
        if sender.isKind(of: NSSegmentedControl.self) {
            zoom = sender.selectedSegment
        } else {
            zoom = (sender.tag)!
        }
        
        switch zoom {
        case 0:
            self.zoomFactor = Double( (self.appDelegate.imageEditorViewController?.imageView.zoomFactor)! + CGFloat(0.02))
             self.appDelegate.imageEditorViewController?.imageView.zoomFactor = CGFloat(self.zoomFactor)
            
             self.appDelegate.imageEditorViewController?.imageView.zoomOut(self)
        case 1:
            self.zoomFactor = Double( (self.appDelegate.imageEditorViewController?.imageView.zoomFactor)! - CGFloat(0.02))
             self.appDelegate.imageEditorViewController?.imageView.zoomFactor = CGFloat(self.zoomFactor)
             self.appDelegate.imageEditorViewController?.imageView.zoomIn(self)
        case 2:
             self.appDelegate.imageEditorViewController?.imageView.zoomImageToActualSize(self)
        case 3:
             self.appDelegate.imageEditorViewController?.imageView.zoomImageToFit(self)
        default:
            break
        }
        
        self.zoomSlider.doubleValue = self.zoomFactor
        self.zoomVerticalSlider.doubleValue = self.zoomFactor

    }
    
    
//    - (IBAction)shareOnTwitter:(id)sender
//    {
//    // Items to share
//    NSAttributedString *text = [self.textView attributedString];
//    NSImage *image = [self.imageView image];
//    NSArray * shareItems = [NSArray arrayWithObjects:text, image, nil];
//    
//    NSSharingService *service = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
//    service.delegate = self;
//    [service performWithItems:shareItems];
//    }
    
    @IBAction func shareAirdrop(sender: AnyObject?) {
        let attr = NSMutableAttributedString(string: "foo")
        let image = NSImage.init(contentsOf: (self.appDelegate.imageEditorViewController?.imageUrl)!)
        
        let shareItems: NSArray? = NSArray(objects: attr,image!, "")
    
        let service = NSSharingService(named: NSSharingServiceNameSendViaAirDrop)!
        
        service.perform(withItems: shareItems as! [Any])
        
    }

    @IBAction func shareFacebook(sender: AnyObject?) {
        
        let fileNameNoExtension = self.appDelegate.imageEditorViewController?.imageUrl?.deletingPathExtension()
        
        let imageName = fileNameNoExtension?.lastPathComponent
        
        let attr = NSMutableAttributedString(string: imageName!)
    
        let image = NSImage.init(contentsOf: (self.appDelegate.imageEditorViewController?.imageUrl)!)
        
        let shareItems: NSArray? = NSArray(objects: attr,image!, "")
        
        let picker = NSSharingServicePicker.init(items: shareItems as! [Any])
        
        picker.show(relativeTo: sender!.bounds, of: sender as! NSView, preferredEdge: NSRectEdge.minY)
    }
    
    
    @IBAction func openPreview(sender: AnyObject?) {
        
        NSWorkspace.shared().open((self.appDelegate.imageEditorViewController?.imageUrl!)!)
    }
    
    
}
