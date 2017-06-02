//
//  ImageFile.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import AVFoundation
import Cocoa

class ImageFile {

    fileprivate(set) var thumbnail: NSImage?
    fileprivate(set) var fileName: String
    fileprivate(set) var imgUrl: URL!
    fileprivate(set) var videoUrl: URL!
    fileprivate(set) var thumbnailUrl: URL!
    fileprivate(set) var thumbnailFileName: String
    fileprivate(set) var asset: AVAsset!
    fileprivate(set) var thumbnailSize =  NSSize(width: 80, height: 40)
    
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
        self.thumbnailFileName = "\(url.deletingPathExtension().lastPathComponent)-thumbnail.\(url.pathExtension).jpg"
        let  tmp = "\(self.appDelegate.appSettings.thumbnailDirectory!)/\(self.thumbnailFileName)".replacingOccurrences(of: " ", with: "%20")
        
        self.thumbnailUrl = URL(string: tmp)
        
        if(self.appDelegate.isMov(file: url)) {
            self.videoUrl = url
            self.asset = AVAsset(url: self.videoUrl)
            
            if !fileManager.fileExists(atPath: getPathFromURL(path: self.thumbnailUrl.absoluteString)) {
                    thumbnail = getThumbnailImageForVideo(asset: self.asset, url: self.thumbnailUrl)
               
            } else {
                let imageSource = CGImageSourceCreateWithURL(self.thumbnailUrl.absoluteURL as CFURL, nil)
                if let imageSource = imageSource {
                    guard CGImageSourceGetType(imageSource) != nil else { return }
                    thumbnail = NSImage.init(contentsOf: self.thumbnailUrl.absoluteURL)
                }
            }
            
        } else {
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
    }
    
    fileprivate func getPathFromURL(path: String) -> String {
        var path = path.replacingOccurrences(of: "file://", with: "")
        path = path.replacingOccurrences(of: "%20" , with: " ")
        return path
    }
    
    fileprivate func getThumbnailImage(_ imageSource: CGImageSource, url: URL!) -> NSImage? {
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

        }
        return img
    }
    
    
    fileprivate func getThumbnailImageForVideo(asset: AVAsset, url: URL) -> NSImage? {
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time        : CMTime = CMTimeMake(1, 30)
        let img         : CGImage
        do {
            try img = assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            
            let frameImg: NSImage = NSImage(cgImage: img, size: self.thumbnailSize)
            
            let data: Data = frameImg.imageJPGRepresentation()! as Data
            
            do {
                try data.write(to: url, options: .withoutOverwriting)
                
                print("File saved FAILED")
                
                return frameImg
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } catch {
            
        }
        return nil
        
    }
    
}
