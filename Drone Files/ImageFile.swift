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
    
    init (url: URL) {
       self.fileName = url.lastPathComponent
       self.imgUrl = url
        let imageSource = CGImageSourceCreateWithURL(url.absoluteURL as CFURL, nil)
        if let imageSource = imageSource {
            guard CGImageSourceGetType(imageSource) != nil else { return }
            thumbnail = getThumbnailImage(imageSource)
        }
    }
    
    fileprivate func getThumbnailImage(_ imageSource: CGImageSource) -> NSImage? {
        let thumbnailOptions = [
            String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
            String(kCGImageSourceThumbnailMaxPixelSize): 160
            ] as [String : Any]
        guard let thumbnailRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) else { return nil}
        return NSImage(cgImage: thumbnailRef, size: NSSize.zero)
    }
    
}
