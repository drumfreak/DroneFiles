//
//  FileFunctions.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 6/9/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class FileFunctions: NSObject {
    
    func getFileModificationDate(originalFile: URL!, offset: Float64) -> Date {
        let date = Date()
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: originalFile.path)
            let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as! Date
            
            
            //print("OFFSET: \(offset)")
            
            let nanoseconds = (offset * 1e+9)
            //print("Nanoseconds \(nanoseconds)")
            //print("Nanoseconds INT \(Int(nanoseconds))")
            
            var newDate = Calendar.current.date(byAdding: .nanosecond, value: Int(nanoseconds), to: modificationDate)
            
            newDate = Calendar.current.date(byAdding: .second, value: Int(offset), to: newDate!)
            
            let dateformatter = DateFormatter()
            
            dateformatter.dateFormat = "HHmm.ss.SSSS"
            
            //print("OLD DATE: \(dateformatter.string(from: modificationDate))")
            
            //print("NEW DATE: \(dateformatter.string(from: newDate!))")
            
            return newDate!
        } catch let error {
            print("Error getting file modification attribute date: \(error.localizedDescription)")
            return date
        }
    }
    
    
    func fileExists(url: URL) -> Bool {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if !fileManager.fileExists(atPath: (url.path), isDirectory: &isDirectory) {
            return false
        } else {
            return true
        }
    }
    
    func setFileDate(originalFile: String, modificationDate: Date) {
        
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        original = original.replacingOccurrences(of: "%20", with: " ");
        do {
            
            let newDate = modificationDate
            let attributes = [
                FileAttributeKey.creationDate: newDate,
                FileAttributeKey.modificationDate: newDate
            ]
            
            do {
                try FileManager.default.setAttributes(attributes, ofItemAtPath: original)
            } catch {
                print(error)
            }
        }
    }
    
    
    func checkFolderAndCreate(folderPath: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(string: folderPath)!, withIntermediateDirectories: true, attributes: nil)
            // print("Created Directory... " + folderPath)
            return true
        } catch _ as NSError {
            print("Error while creating a folder.")
            return false
        }
    }
    
}
