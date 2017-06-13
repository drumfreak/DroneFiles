//
//  VideoFileManager.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 6/13/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//


import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz
import CoreData

class VideoFileManager: NSObject {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var videoFiles: [VideoFile] = []
    
    var project: Project!
    
    var fecthVideoFileRequest = NSFetchRequest<NSManagedObject>(entityName: "VideoFile")
    
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    var appSettings:AppSettings {
        return appDelegate.appSettings
    }
    
    override init() {
        super.init()
    }
    
    
    func getVideoFile(url: URL) -> VideoFile {
        print("APP DELEGATE PROJECT: \(String(describing: self.appDelegate.project))")

        let managedObjectContext = self.appDelegate.persistentContainer.viewContext
        
        let fetch = self.fecthVideoFileRequest
        fetch.predicate = NSPredicate(format: "fileUrl == %@", url.absoluteString)
        
        do {
            let videos = try managedObjectContext.fetch(fetch)
            
            if(videos.count > 0) {
                let videoFile = videos[0] as! VideoFile
                print("Video Found: \(String(describing: videoFile.fileName))")
                
                
                print("VIDEO SIZE: \(String(describing: videoFile.fileSize))")
                print("VIDEO Date: \(String(describing: videoFile.fileDate))")
                print("VIDEO URL: \(String(describing: videoFile.fileUrl))")
                print("VIDEO PROJECT: \(String(describing: videoFile.project))")
                print("VIDEO PROJECT Videos: \(String(describing: videoFile.project?.videos))")

                
                return videoFile
            } else {
                let entity =
                    NSEntityDescription.entity(forEntityName: "VideoFile",
                                               in: managedObjectContext)!
                
                let videoFile = NSManagedObject(entity: entity,
                                            insertInto: managedObjectContext) as! VideoFile
        
        
                // it's not been processed.
                
                let location = self.getLocationFromVideo(url: url)
                
                let playerItem = AVPlayerItem(url: url)
                
                let videoLength = playerItem.duration.seconds
                
                let size = self.getVideoSize(url: url)
                
                let fps = self.getVideoFPS(url: url)
                
                var fileSize : UInt64
                var fileSystemFileNumber : UInt64
                
                do {
                    //return [FileAttributeKey : Any]
                    let attr = try FileManager.default.attributesOfItem(atPath: url.path)
                    fileSize = attr[FileAttributeKey.size] as! UInt64
                    let date = attr[FileAttributeKey.modificationDate] as! NSDate
                    fileSystemFileNumber = attr[FileAttributeKey.systemFileNumber] as! UInt64
                    
                    
                    //if you convert to NSDictionary, you can get file size old way as well.
                    let dict = attr as NSDictionary
                    fileSize = dict.fileSize()
                    
                    videoFile.fileName = url.lastPathComponent
                    videoFile.videoFPS = fps
                    videoFile.videoWidth = Float(size.width)
                    videoFile.videoHeight = Float(size.height)
                    videoFile.videoLength = videoLength
                    if(location.count > 1) {
                        videoFile.videoLocationLat = location[0]
                        videoFile.videoLocationLatRef = (location[1] == 0) ? "N" : "S"
                        videoFile.videoLocationLong = location[2]
                        videoFile.videoLocationLongRef = (location[3] == 0) ? "W" : "E"
                        videoFile.videoLocation = "\(location[0]) \(videoFile.videoLocationLatRef!),\(location[2]) \(videoFile.videoLocationLongRef!)"
                    }
                    
                    videoFile.fileDate = date
                    videoFile.fileSize = Int64(fileSize)
                    videoFile.fileSystemFileNumber = Int64(fileSystemFileNumber)
                    videoFile.fileUrl = url.absoluteString
                    videoFile.project = self.appDelegate.project
                    
                    
                    
                    
                    // 4
                    do {
                        try managedObjectContext.save()
                        print("VIDEO FILE: \(String(describing: videoFile.fileName))")
                        print("VIDEO Date: \(String(describing: videoFile.fileDate))")
                        print("VIDEO URL: \(String(describing: videoFile.fileUrl))")
                        print("VIDEO PROJECT: \(String(describing: videoFile.project))")

                        return videoFile
                    } catch let error as NSError {
                        print("Could not save VideoFile. \(error), \(error.userInfo)")
                        return VideoFile()
                    }
                    
                    //print(dict)
                } catch {
                    print("Read File Attributes Error: \(error)")
                    return VideoFile()
                }
                
            }
        } catch {
            print("Read File Attributes Error: \(error)")
            return VideoFile()
        }
        
    }

    
    func getVideoFPS(url: URL) -> Float {
        let asset = AVAsset(url: url)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)
        let fps = assetTrack[0].nominalFrameRate
        return fps
    }
    
    
    func getVideoSize(url: URL) -> CGSize {
        let asset = AVAsset(url: url)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)
        let size = assetTrack[0].naturalSize as CGSize
        return size
    }
    
    
    func getLocationFromVideo(url: URL) -> [Double] {
        
        var location = ""
        let asset = AVAsset(url: url)
        
        for metaDataItems in asset.commonMetadata {
            if metaDataItems.commonKey == "location" {
                location = (metaDataItems.value as! NSString) as String
                //print("Location Data: \(locationData)")
            } else {
                
            }
        }
        
        if(location.characters.count > 0) {
            if let range = location.range(of: "-") {
                
                let latFull = location[location.startIndex..<range.lowerBound]
                
                let longFull = location[range.lowerBound..<location.endIndex]
                
                let lat = latFull.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "\\", with: "")
                
                var long = longFull.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "\\", with: "")
                
                var longArray = long.components(separatedBy: ".")
                
                longArray.removeLast()
                
                long = longArray.joined(separator: ".")
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                
                let finalLong = numberFormatter.number(from: long)
                let finalLat = numberFormatter.number(from: lat)
                
                //print("Long: \(finalLong as Any)")
                //print("Lat: \(finalLat as Any)")
                
                let longitude = finalLong?.doubleValue
                
                let latitude = finalLat?.doubleValue
                
                var latRef = 0 // 0 for south / 1 for north
                var longRef = 0 // 0 for West / 1 for East
                if var lat = latitude {
                    if lat < 0 {
                        latRef = 0
                        lat = -lat
                    } else {
                        latRef = 1
                    }
                }
                
                if var lon = longitude {
                    if lon < 0 {
                        longRef = 0
                        lon = -lon
                    } else {
                        longRef = 1
                    }
                }
                
                if(latitude == nil || longitude == nil) {
                    return []
                } else {
                    return [latitude!, Double(latRef), longitude!, Double(longRef)]
                }
                
            }
        }
        return []
    }
}
