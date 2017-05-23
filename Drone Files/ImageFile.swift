//
//  ImageFile.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation

import Cocoa

class ImageFile {
    
 
    
    fileprivate(set) var thumbnail: NSImage?
    fileprivate(set) var fileName: String
    fileprivate(set) var imgUrl: URL!
    fileprivate(set) var thumbnailUrl: URL!
    fileprivate(set) var thumbnailFileName: String

    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    var appSettings:AppSettings {
        return appDelegate.appSettings
    }
    let fileManager = FileManager.default

    
    init (url: URL) {
        self.fileName = url.lastPathComponent
        self.imgUrl = url
        
        
        self.thumbnailFileName = url.deletingPathExtension().lastPathComponent
        self.thumbnailFileName += "-thumbnail"
        self.thumbnailFileName += "." + url.pathExtension
        var  tmp = self.appDelegate.appSettings.thumbnailDirectory! + self.thumbnailFileName
        tmp =  tmp.replacingOccurrences(of: " ", with: "%20")
        
        self.thumbnailUrl = URL(string: tmp)
        // var isDirectory: ObjCBool = false

        if !fileManager.fileExists(atPath: getPathFromURL(path: self.thumbnailUrl.absoluteString)) {
            
            // No thumbnail exists.
            // print("Thumbnail does not exist")
            let imageSource = CGImageSourceCreateWithURL(url.absoluteURL as CFURL, nil)
            if let imageSource = imageSource {
                guard CGImageSourceGetType(imageSource) != nil else { return }
                thumbnail = getThumbnailImage(imageSource, url: self.thumbnailUrl)
            }
        } else {
            
            let imageSource = CGImageSourceCreateWithURL(self.thumbnailUrl.absoluteURL as CFURL, nil)
            
            if let imageSource = imageSource {
            
                guard CGImageSourceGetType(imageSource) != nil else { return }
            
                thumbnail = NSImage.init(contentsOf: self.thumbnailUrl.absoluteURL)
                
            
            }
        }
        
       

    }
    
    fileprivate func getPathFromURL(path: String) -> String {
        var path = path.replacingOccurrences(of: "file://", with: "")
        path = path.replacingOccurrences(of: "%20" , with: " ")
        return path
    }
    
    fileprivate func getThumbnailImage(_ imageSource: CGImageSource, url: URL!) -> NSImage? {
        
        // Get thumbnail name
        
        let thumbnailOptions = [
            String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
            String(kCGImageSourceThumbnailMaxPixelSize): 80
            ] as [String : Any]
        
        
        guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}

        
        let img = NSImage(cgImage: thumbnailRef, size: NSSize.zero)
        
        let imageUTType = CGImageSourceGetType(imageSource)
        
        
        let dest = CGImageDestinationCreateWithURL(url! as CFURL, imageUTType! as CFString, 1, nil)
        
        
        if ((dest) != nil)
        {
            CGImageDestinationAddImage(dest!, thumbnailRef, thumbnailOptions as CFDictionary)
            CGImageDestinationFinalize(dest!)
            
            //self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: self.saveUrl.absoluteString)
            // self.appDelegate.imageEditorViewController?.loadImage(_url: self.saveUrl!)
            
        }

        
       
        
        
        return img
        
        
    }
    
}
