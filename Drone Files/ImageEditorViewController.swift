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
        imageView.autoresizes = true
        imageView.supportsDragAndDrop = true
        imageView.editable = true
        
        self.scrollView.hasVerticalScroller = false
        self.scrollView.hasHorizontalScroller = false
        
        let rgb = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        imageView.backgroundColor = rgb
   

    }
    
        
    func setWindowVisible(sender : AnyObject?) {
        // self.window!.orderFront(self)
        
        //print("FUCK");
    }
    
    
    func loadImage(_url: URL) {
        // imageView.show
        self.imageUrl = _url
        imageView.setImageWith(_url)
        //print("Loaded Image")
        
        if(self.appDelegate.imageEditorControlsController?.viewIsLoaded)! {
            //print("Resetting..")
            self.appDelegate.imageEditorControlsController?.resetImage(self)
        }
        
        self.imageView.zoomImageToFit(self)


    }
    
    
    
    
    
//    func loadImage(_url: URL) {
//    
//        self.imageUrl = _url
//        
//        let image = CGImageSourceCreateWithURL(_url as CFURL, nil)
//        
//        let imageUTType = CGImageSourceGetType(image!)
//
//        let imageProps = CGImageSourceCopyProperties(image!, imageProperties)
//        
//        self.imageView.setImage(image, imageProperties: imageProps as! [AnyHashable : Any])
//        
//        
//        
//        self.saveOptions = IKSaveOptions.init(imageProperties: self.imageView.imageProperties(), imageUTType: imageUTType! as String)
//
//    }

}
