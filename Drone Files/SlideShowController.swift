//
//  SlideShowController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/13/17.
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

class SlideShowController: NSViewController {
    var mSlideshow = IKSlideshow.shared()
    var mImagePaths = NSMutableArray() {
        didSet {
            // print("Reloaded mImagePaths")
            
            // print(self.mImagePaths)
            if(self.slideshowRunning) {
                self.mSlideshow?.reloadData()
            }
        }
    }
    
    var slideshowRunning = false
    
    
    //  var dataSource: IKSlideshowDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.appDelegate.slideShowController = self
        
        self.mSlideshow?.autoPlayDelay = TimeInterval(Int(0))
        
        if(self.mImagePaths.count > 0) {
            self.mSlideshow?.run(with: self, inMode: IKSlideshowModeOther, options: nil)
            
        }
    }
    
    func loadImages(items: NSMutableArray) {
        self.mImagePaths = items
        self.mSlideshow?.autoPlayDelay = TimeInterval(Int(0))
        
        if(self.mImagePaths.count > 0) {
            self.mSlideshow?.run(with: self, inMode: IKSlideshowModeOther, options: nil)
        }
        
        if(self.slideshowRunning) {
            self.mSlideshow?.reloadData()
            
        }
    }
    
    // Datasource stuff
    
    func numberOfSlideshowItems() -> Int {
        return self.mImagePaths.count
    }
    
    
    //    func slideshowItem(at: Int) -> String {
    //
    //        return "Foo"
    //
    //    }
    
    //    func nameOfSlideshowItem(at: Int) -> String {
    //
    //        return "String"
    //    }
    
}


extension SlideShowController: IKSlideshowDataSource {
    /*!
     @method slideshowItemAtIndex:
     @abstract return the item for a given index.
     @discussion The item can be either: NSImage, NSString, NSURL, CGImageRef, or PDFPage.
     Note: when using 'IKSlideshowModeOther' as slideshowMode, the item has to be a NSURL.
     */
    
    func slideshowItem(at index: Int) -> Any! {
        let i = index % self.mImagePaths.count
        return self.mImagePaths.object(at:i)
    }
    
    
    /*
     @method nameOfSlideshowItemAtIndex:
     @abstract Display name for item at index.
     */
    
    //    private func nameOfSlideshowItem(at index: Int) -> String! {
    //        print("Foo")
    //
    //        return "Foo"
    //    }
    //
    
    /*!
     @method canExportSlideshowItemAtIndex:toApplication:
     @abstract should the export button be enabled for a given item at index?
     */
    internal func canExportSlideshowItem(at index: Int, toApplication applicationBundleIdentifier: String!) -> Bool {
        
        return true
    }
    
    
    /*!
     @method slideshowWillStart
     @abstract Slideshow will start.
     */
    internal func slideshowWillStart() {
        print("Fuck slideshow started")
        self.slideshowRunning = true
    }
    
    
    /*!
     @method slideshowDidStop
     @abstract Slideshow did stop.
     */
    internal func slideshowDidStop() {
        print("Fuck slideshow stopped")
        self.slideshowRunning = false
        
    }
    
    
    /*!
     @method slideshowDidChangeCurrentIndex:
     @abstract Slideshow did change current item index.
     */
    
    
}

