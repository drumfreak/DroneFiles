//
//  VideoTools.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 6/9/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa
import AVFoundation
import Quartz
import CoreData

class VideoTools: NSObject {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    var fetchThumbnailRequest = NSFetchRequest<NSManagedObject>(entityName: "Thumbnail")

    

    
    func createThumbnailObject(asset: AVAsset, time: CMTime) -> Thumbnail {
        
        // Get the thumbnail data first.
        
        let imageData = generateThumbnailDataForTimeStamp(asset: asset, time: time, size: NSSize(width: 120, height: 60))
        
        managedObjectContext = self.appDelegate.persistentContainer.viewContext

        let entity =
            NSEntityDescription.entity(forEntityName: "Thumbnail",
                                       in: managedObjectContext)!
        
        let thumbnail = NSManagedObject(entity: entity,
                                    insertInto: managedObjectContext)
        
        // 3
        thumbnail.setValue(imageData, forKeyPath: "data")
        
        // 4
        do {
            try managedObjectContext.save()
            return thumbnail as! Thumbnail
        } catch let error as NSError {
            print("Could not saving VideoFile. \(error), \(error.userInfo)")
            return Thumbnail()
        }
        
    }
    
    func generateThumbnailDataForTimeStamp(asset: AVAsset, time: CMTime, size: NSSize) -> Data? {
        
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let img         : CGImage
        do {
            try img = assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let frameImg: NSImage = NSImage(cgImage: img, size: size)
            let data: Data = frameImg.imageJPGRepresentation()! as Data
            return data
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    func trimClipAndSave(url: URL, startTime: CMTime, endTime: CMTime) {
        
        
        
    }
    
    func writeImageDataToFile(data: Data, url: URL) {
        
        do {
            try data.write(to: url, options: .withoutOverwriting)
            
            // print("File saved FAILED")
            
            // return frameImg
        } catch {
            print(error.localizedDescription)
            // return nil
        }

    }

    
    
}
