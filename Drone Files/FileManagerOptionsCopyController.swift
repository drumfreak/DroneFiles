//
//  FileManagerOptionsCopyController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/25/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation

class FileManagerOptionsCopyController: NSViewController {
    @IBOutlet weak var fileBrowserViewController: FileBrowserViewController!
    @IBOutlet weak var fileManagerViewController: FileManagerViewController!
    @IBOutlet  var fileManagerOptionsTabViewController: FileManagerOptionsTabViewController!
    
    var copyToFolder = ""
    
    
    @IBOutlet var numberofFilesLabel: NSTextField!
    
    var receivedFiles = NSMutableArray() {
        didSet {
            print("Received Files on COPY Controller \(receivedFiles)")
            let count = String(format: "%02d", receivedFiles.count)
            self.numberofFilesLabel.stringValue = "(" + count  + ")"
        }
    }
    
    
    
    @IBOutlet var copyDirectoryLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("FileManagerOptionsCopyController loaded")
        self.copyToFolder = self.fileManagerOptionsTabViewController.fileBrowserViewController.outputDirectory
        
        self.copyDirectoryLabel.stringValue = self.copyToFolder
    }
    
    
    func pathOutputFromURL(inputString: String) -> String {
        let str = inputString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        return str
    }
    
    
    @IBAction func copyFiles(_ sender: AnyObject) {
        let manageFileURLS: NSMutableArray = []
        let fileUrls = self.receivedFiles as! Array<Any>
        
        // print("SELECTED ITEMS \(item.url)")
        if(fileUrls.count > 0) {
            fileUrls.forEach({ m in
                
                let urlPath = m as! String
                let url = NSURL(fileURLWithPath: urlPath)
                
                if(self.copyFile(url: url as URL)) {
                    manageFileURLS.add(url)
                }
                
            })
            
            self.fileManagerOptionsTabViewController?.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)
            
            //showNotification(messageType: "OrganizeFiles", customMessage: "No Files Selected!")
            showAlert(text: "Files Copied!", body: "The files have been copied!", showCancel: false, messageType: "warning")
            
            // showNotification(messageType: "OrganizeFiles", customMessage: self.fileBrowserViewController.videoFolder)
            
        } else {
            //showNotification(messageType: "OrganizeFiles", customMessage: "No Files Selected!")
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
        }
    }
    
    func copyFile(url: URL) -> Bool {
        print("Copying File! ... \(url)")
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.videoFolder)
        
        var newMovieFile = self.fileBrowserViewController.videoFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".MOV" // for now
        
        newMovieFile = newMovieFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newMovieFile)!)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
    }
    
    func moveFile(from: URL, toUrl: URL) -> Bool {
        do {
            try FileManager.default.moveItem(at: from, to: toUrl)
            return true
        }
        catch let error as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: \(error)")
            showAlert(text: "Could not copy file", body:("This file " + from.absoluteString + " could not be moved"), showCancel: false, messageType: "warning")
            
            return false
        }
    }
    
    func checkFolderAndCreate(folderPath: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(string: folderPath)!, withIntermediateDirectories: true, attributes: nil)
            print("Created Directory... " + folderPath)
            return true
        } catch _ as NSError {
            print("Error while creating a folder.")
            return false
        }
    }
    
    func getFileIncrementAtPath(path: String) -> String {
        var incrementer = "00"
        let Urlpath = path
        let path = getPathFromURL(path: path)
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: Urlpath)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%02d", files.count)
                
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        return incrementer
    }
    
    func getPathFromURL(path: String) -> String {
        var path = path.replacingOccurrences(of: "file://", with: "")
        path = path.replacingOccurrences(of: "%20" , with: " ")
        return path
    }
    
    func showAlert(text: String, body: String, showCancel: Bool, messageType: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = text
        myPopup.informativeText = body
        myPopup.alertStyle = NSAlertStyle.warning
        myPopup.addButton(withTitle: "OK")
        if(showCancel) {
            myPopup.addButton(withTitle: "Cancel")
        }
        myPopup.runModal()
    }
    
    
}
