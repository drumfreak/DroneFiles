//
//  FileManagerOptionsMoveController.swift
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


class FileManagerOptionsMoveController: NSViewController {
    @IBOutlet weak var fileBrowserViewController: FileBrowserViewController!
    @IBOutlet weak var fileManagerViewController: FileManagerViewController!
    @IBOutlet  var fileManagerOptionsTabViewController: FileManagerOptionsTabViewController!
    
    
    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var chooseMoveDestinationButton1: NSButton!
    @IBOutlet var moveDirectoryLabel: NSTextField!
    
    var moveToFolder = "/Volumes/"
    
    var viewIsLoaded = false
    
    var receivedFiles = NSMutableArray() {
        didSet {
            //  print("Received Files on COPY Controller \(receivedFiles)")
            if(self.viewIsLoaded) {
                let count = String(format: "%", receivedFiles.count)
                self.numberofFilesLabel.title = count
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("FileManagerOptionsMoveController loaded")
        
        if(UserDefaults.standard.value(forKey: "moveToFolder") == nil) {
            self.moveToFolder = self.fileManagerOptionsTabViewController.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.moveToFolder, forKey: "copyToFolder1")
        } else {
            self.moveToFolder = UserDefaults.standard.value(forKey: "moveToFolder") as! String
        }
        
        self.moveDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.moveToFolder)
        
        // Click Gestures
        
        let tapGestureCopyFolder1 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath1))
        self.moveDirectoryLabel.addGestureRecognizer(tapGestureCopyFolder1)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.viewIsLoaded = false
    }
    
    
    func pathOutputFromURL(inputString: String) -> String {
        let str = inputString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        return str
    }
    
    @IBAction func chooseMoveDestinationFolder(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                //print(openPanel.urls)
                
                self.moveToFolder = (openPanel.url?.absoluteString)!
                
                UserDefaults.standard.setValue(self.moveToFolder, forKey: "moveToFolder")
                
                self.moveDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
                
            }
        })
    }
    
    
    func fileOperationComplete(manageFileURLS: NSMutableArray, errors: Bool) {
        self.fileManagerOptionsTabViewController?.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)
        
        self.fileBrowserViewController?.reloadFilesWithSelected(fileName: "")
        if(!errors) {
            showAlert(text: "Files Moved!", body: "The files have been moved!", showCancel: false, messageType: "notice")
        }
    }
    
    
    @IBAction func moveFilesFolder1(_ sender: AnyObject) {
        let manageFileURLS: NSMutableArray = []
        let fileUrls = self.receivedFiles as! Array<Any>
        
        if(fileUrls.count > 0) {
            var errors = false
            if(fileUrls.count > 0) {
                DispatchQueue.global(qos: .userInitiated).async {
                    fileUrls.forEach({ m in
                        fileUrls.forEach({ m in
                            let urlPath = m as! String
                            let url = URL(string: urlPath)
                            
                            if(self.moveFilesFolder1(url: url!)) {
                                manageFileURLS.add(url!)
                            } else {
                                errors = true
                            }
                        })
                        DispatchQueue.main.async {
                            self.fileOperationComplete(manageFileURLS: manageFileURLS, errors: errors)
                        }
                    })
                }
            }
            
        } else {
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
        }
    }
    
    
    
    
    func moveFilesFolder1(url: URL) -> Bool {
        print("Moving File! ... \(url)")
        
        // let tmpURL = NSURL(fileURLWithPath: url.absoluteString)
        let fileName = url.lastPathComponent
        
        print("Moving FROM filename: \(fileName)")
        
        var moveDestination = ""
        moveDestination = self.moveToFolder + fileName
        
        //  copyDestination = getPathFromURL(path: copyDestination)
        moveDestination = moveDestination.replacingOccurrences(of: " ", with: "%20")
        
        print("Move DESTINATION: \(moveDestination)")
        
        let destinationURL = URL(string: moveDestination)!
        
        if(self.doMoveFile(from: url, toUrl: destinationURL)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
    }
    
    func doMoveFile(from: URL, toUrl: URL) -> Bool {
        
        print("FROM: \(from)")
        print("TO: \(toUrl)")
        
        do {
            try FileManager.default.moveItem(at: from, to: toUrl)
            return true
        }
        catch _ as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: ")
            showAlert(text: "Could not move file", body:("This file " + from.absoluteString + " could not be moved"), showCancel: false, messageType: "warning")
            
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
    
    func urlStringToDisplayURLString(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    func urlStringToDisplayPath(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    func setOpenPath1() {
        doOpenFinder(urlString:self.moveToFolder)
    }
    
    
    func doOpenFinder(urlString: String) {
        let path = pathOutputFromURL(inputString: urlString)
        
        if FileManager.default.fileExists(atPath: path) {
            let url = URL(string: urlString)!
            
            NSWorkspace.shared().open(url)
        } else {
            showAlert(text: "That Folder Doesn't Exist", body: "Select a folder and try again.", showCancel: false, messageType: "warning")
        }
    }
}
