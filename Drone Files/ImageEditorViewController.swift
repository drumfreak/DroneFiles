//
//  ImageEditorViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/21/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz
import Photos
import PhotosUI



class ImageEditorViewController: NSViewController {
    
    var menuItem : NSMenuItem = NSMenuItem()
    var mainMenu = NSMenu()
    
    
    @IBOutlet var scrollView: NSScrollView!
    @IBOutlet var imageView: IKImageView!
    @IBOutlet var imageName: NSTextField!
    @IBOutlet var imageEditorView: NSView!
    
    @IBOutlet weak var dateField: NSTextField!
    @IBOutlet weak var flightName: NSTextField!
    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet var saveDirectoryName: String!
    @IBOutlet var flightNameVar: String!
    @IBOutlet var dateNameVar: String!
    @IBOutlet var folderURL: String!
    @IBOutlet weak var folderURLDisplay: NSTextField!
    var nowPlayingURL: URL!
    var imageUrl: URL!
    @IBOutlet weak var nowPlayingFile: NSTextField!
    var nowPlayingURLString: String!
    
    
    var imageProperties: NSDictionary = Dictionary<String, String>() as NSDictionary
    var imageUTType: String = ""
    var saveOptions: IKSaveOptions = IKSaveOptions()

    override func viewDidLoad() {
        super.viewDidLoad()
        // print("Loaded Image Editor")
        self.imageView.autoresizes = true
        self.imageView.supportsDragAndDrop = true
        self.imageView.editable = true
        
        self.scrollView.hasVerticalScroller = false
        self.scrollView.hasHorizontalScroller = false
        
        let rgb = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        self.imageView.backgroundColor = rgb
        
        self.appDelegate.imageEditorViewController = self
        
       // print("This is kind of happening.......")
        
        self.view.wantsLayer = true
        
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor

    }

    func loadImage(_url: URL) {
        
        print("Loading IMAGES: \(_url)")
        
        // imageView.show
        self.imageUrl = _url
        self.imageView.setImageWith(_url)
        
        self.nowPlayingURL = _url
        self.nowPlayingFile?.stringValue = self.nowPlayingURL.lastPathComponent
        self.nowPlayingURLString = _url.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        //print("Loaded Image")
        
        if(self.appDelegate.imageEditorControlsController?.viewIsLoaded)! {
            //print("Resetting..")
            self.appDelegate.imageEditorControlsController?.resetImage(self)
        }
        
        self.imageView.zoomImageToFit(self)
        
        
        
        let imageSource = CGImageSourceCreateWithURL(_url as CFURL, nil)
        if((imageSource) != nil) {
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! [String:Any]
            
            // let exifDict = imageProperties["Exif"] as! Dictionary
            
            
            print(imageProperties)
        }
     
        
    }
}
