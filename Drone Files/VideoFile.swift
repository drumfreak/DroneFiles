//
//  VideoFile.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//
import Cocoa
import Foundation
import AVFoundation


class VideoFile {
    
    fileprivate(set) var thumbnail: NSImage?
    fileprivate(set) var fileName: String
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
        self.videoUrl = url
        self.thumbnailFileName = url.deletingPathExtension().lastPathComponent
        self.thumbnailFileName += "-videothumbnail"
        self.thumbnailFileName += "." + url.pathExtension
        
        self.asset = AVAsset(url: self.videoUrl)
        
        var  tmp = self.appDelegate.appSettings.thumbnailDirectory! +
            "/" + self.thumbnailFileName
        tmp =  tmp.replacingOccurrences(of: " ", with: "%20")
        
        self.thumbnailUrl = URL(string: tmp)
        self.asset = AVAsset(url: self.videoUrl)

        if !fileManager.fileExists(atPath: getPathFromURL(path: self.thumbnailUrl.absoluteString)) {
            let imageSource = CGImageSourceCreateWithURL(url.absoluteURL as CFURL, nil)
            if let imageSource = imageSource {
                guard CGImageSourceGetType(imageSource) != nil else { return }
                thumbnail = getThumbnailImage(asset: asset, url: self.thumbnailUrl)
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
    
    fileprivate func getThumbnailImage(asset: AVAsset, url: URL) -> NSImage? {
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
