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
    
    var imageViewLoad = IKImageView()
    
    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet var saveDirectoryName: String!
    @IBOutlet var folderURL: String!
    @IBOutlet weak var folderURLDisplay: NSTextField!
    var preLoadedImage: CGImage!
    var nowPlayingURL: URL!
    var imageUrl: URL!
    //    @IBOutlet weak var nowPlayingFile: NSTextField!
    //    var nowPlayingURLString: String!
    
    
    var imageProperties: NSDictionary = Dictionary<String, String>() as NSDictionary
    var imageUTType: String = ""
    var saveOptions: IKSaveOptions = IKSaveOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //DispatchQueue.main.async {
            self.view.wantsLayer = true
            self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
            // print("Loaded Image Editor")
            self.imageView.autoresizes = true
            self.imageView.supportsDragAndDrop = true
            self.imageView.editable = true
            
            self.scrollView.hasVerticalScroller = false
            self.scrollView.hasHorizontalScroller = false
            
            let rgb = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
            self.imageView.backgroundColor = rgb
            
       // }
        
        self.appDelegate.imageEditorViewController = self
        
        // print("This is kind of happening.......")
        
    }
    
    
    func windowDidResize (notification: NSNotification?) {
       // DispatchQueue.main.async {
            self.imageView.zoomImageToFit(self)
      //  }
    }
    
    override func viewDidLayout() {
        // Swift.print("view has been resize to \(self.view.frame)")
        super.viewDidLayout()
        
       // DispatchQueue.main.async {
            self.imageView.zoomImageToFit(nil)
       // }
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        //DispatchQueue.main.async {
            self.view.wantsLayer = true
            self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
       // }
    }
    
    
    func loadImage (_url: URL) {
        DispatchQueue.main.async {
            self.imageUrl = _url
            
            self.imageViewLoad.setImageWith(self.imageUrl!)
            self.preLoadedImage = self.imageViewLoad.image().takeUnretainedValue()
            
            if(self.appDelegate.appSettings.mediaBinSlideshowRunning) {
                self.transitionFade()
                
            } else {
                self.transitionNone()
            }
            
        }
    }
    
    
    func transitionNone() {
        self.imageView.setImage(self.preLoadedImage, imageProperties: [:])
        
        self.imageView.zoomImageToFit(self)
    }
    
    
    func transitionFade() {
        NSAnimationContext.runAnimationGroup({context in
            context.duration = 0.5
            self.imageView.alphaValue = 0.0
        }) {
            self.imageView.setImage(self.preLoadedImage, imageProperties: [:])
            self.imageView.zoomImageToFit(self)
            NSAnimationContext.runAnimationGroup({context in
                context.duration = 1.0
                self.imageView.alphaValue = 1.0
            }) {
            }
        }
    }
    
//    func transitionCrossFade() {
//        var lastImage: CGImage!
//        self.imageView.setImageWith(self.imageUrl)
//        self.imageView.zoomImageToFit(self)
//        NSAnimationContext.runAnimationGroup({context1 in
//            context1.duration = 0.5
//            self.imageView.isHidden = true
//            if(self.imageView.image() != nil) {
//                lastImage = self.imageView.image().takeUnretainedValue()
//            }
//        }) {
//            NSAnimationContext.runAnimationGroup({context2 in
//                context2.duration = 2.5
//                self.imageView.isHidden = false
//            }) {
//                self.imageViewBackground.setImage(lastImage, imageProperties: nil)
//                self.imageViewBackground.zoomImageToFit(self)
//            }
//        }
//    }
    

}
