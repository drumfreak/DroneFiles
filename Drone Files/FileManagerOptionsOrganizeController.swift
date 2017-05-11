//
//  FileManagerOptionsOrganizeController.swift
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


class FileManagerOptionsOrganizeController: NSViewController {    
    @IBOutlet var projectDirectoryLabel: NSTextField!
    @IBOutlet var videosDirectoryLabel: NSTextField!
    @IBOutlet var jpgDirectoryLabel: NSTextField!
    @IBOutlet var rawDirectoryLabel: NSTextField!
    @IBOutlet var screenshotDirectoryLabel: NSTextField!
    var viewIsLoaded = false
    
    @IBOutlet var numberofFilesLabel: NSButton!
    
    var receivedFiles = NSMutableArray() {
        didSet {
            // print("Received Files on Organize Controller \(receivedFiles)"
            let count = String(format: "%2d", receivedFiles.count)
            self.numberofFilesLabel.title = count
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("FileManagerOptionsOrganizeController loaded")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        self.setupProjectPaths()
    }
    
    func setupProjectPaths() {
        if(!self.viewIsLoaded) {
            return
        }
        let projectPath = pathOutputFromURL(inputString: self.appDelegate.fileBrowserViewController.projectFolder)
        
        self.projectDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.appDelegate.fileBrowserViewController.projectFolder)
        
        self.videosDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.appDelegate.fileBrowserViewController.videoFolder).replacingOccurrences(of: projectPath, with: "")
        
        self.jpgDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.appDelegate.fileBrowserViewController.jpgFolder).replacingOccurrences(of: projectPath, with: "")
        
        self.rawDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.appDelegate.fileBrowserViewController.rawFolder).replacingOccurrences(of: projectPath, with: "")
        
        self.screenshotDirectoryLabel.stringValue = pathOutputFromURL(inputString: self.appDelegate.fileBrowserViewController.screenShotFolder).replacingOccurrences(of: projectPath, with: "")
        
        
        // Click Gestures
        
        let tapGestureFolder1 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath1))
        
        self.projectDirectoryLabel.addGestureRecognizer(tapGestureFolder1)
        
        let tapGestureFolder2 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath2))
        
        self.videosDirectoryLabel.addGestureRecognizer(tapGestureFolder2)
        
        
        let tapGestureFolder3 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath3))
        
        self.jpgDirectoryLabel.addGestureRecognizer(tapGestureFolder3)
        
        let tapGestureFolder4 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath4))
        
        self.screenshotDirectoryLabel.addGestureRecognizer(tapGestureFolder4)
        
        let tapGestureFolder5 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath5))
        
        self.rawDirectoryLabel.addGestureRecognizer(tapGestureFolder5)
        
    }
    
    func pathOutputFromURL(inputString: String) -> String {
        let str = inputString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        return str
    }
    
    
    
    func fileOperationComplete(manageFileURLS: NSMutableArray, errors: Bool) {
        self.appDelegate.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)
        
        self.appDelegate.fileBrowserViewController?.reloadFilesWithSelected(fileName: "")
        if(!errors) {
            showAlert(text: "Files Organized!", body: "The files have been organized!", showCancel: false, messageType: "notice")
        }
    }
    
    
    @IBAction func organizeFiles(_ sender: AnyObject) {
        let manageFileURLS: NSMutableArray = []
        let manageFileMovies: NSMutableArray = []
        let manageFileScreenshots: NSMutableArray = []
        let manageFileJPG: NSMutableArray = []
        let manageFileRAW: NSMutableArray = []
        let manageFileOther: NSMutableArray = []
        
        let fileUrls = self.receivedFiles as! Array<Any>
        
        // print("SELECTED ITEMS \(item.url)")
        if(fileUrls.count > 0) {
            var errors = false
            DispatchQueue.global(qos: .userInitiated).async {
                
                fileUrls.forEach({ m in
                    let urlPath = m as! String
                    let url = NSURL(fileURLWithPath: urlPath)
                    let _extension = url.pathExtension
                    var skip = false
                    
                    // item.index = index
                    
                    if(_extension == "MOV" || _extension == "mov" || _extension == "mp4" || _extension == "MP4" || _extension == "m4v" || _extension == "M4V") {
                        manageFileMovies.add(URL(string: urlPath)!)
                        skip = true
                    }
                    
                    if(_extension == "JPG" || _extension == "jpg" || _extension == "jpeg" || _extension == "JPEG") {
                        manageFileJPG.add(URL(string: urlPath)!)
                        skip = true
                    }
                    
                    if(_extension == "DNG" || _extension == "dng" ||  _extension == "RAW" ||  _extension == "raw") {
                        manageFileRAW.add(URL(string: urlPath)!)
                        skip = true
                    }
                    
                    if(_extension == "png" || _extension == "PNG") {
                        manageFileScreenshots.add(URL(string: urlPath)!)
                        skip = true
                    }
                    
                    if(!skip) {
                        manageFileOther.add(URL(string: urlPath)!)
                    }
                })
                
                
                if(manageFileMovies.count > 0) {
                    if(self.checkFolderAndCreate(folderPath: self.appDelegate.fileBrowserViewController.videoFolder)) {
                        print("VIDEOS FOLDER: \(self.appDelegate.fileBrowserViewController.videoFolder)")
                        manageFileMovies.forEach({ m in
                            let url = (m as! URL)
                            //print(movie)
                            if(self.organizeMovieFile(url: url)) {
                                manageFileURLS.add(url)
                            } else {
                                errors = true
                            }
                        })
                    }
                }
                
                if(manageFileJPG.count > 0) {
                    if(self.checkFolderAndCreate(folderPath: self.appDelegate.fileBrowserViewController.jpgFolder)) {
                        manageFileJPG.forEach({ m in
                            let url = (m as! URL)
                            if(self.organizeJPGFile(url: url)) {
                                manageFileURLS.add(url)
                            } else {
                                errors = true
                            }
                        })
                    }
                }
                
                if(manageFileScreenshots.count > 0) {
                    if(self.checkFolderAndCreate(folderPath: self.appDelegate.fileBrowserViewController.screenShotFolder)) {
                        manageFileScreenshots.forEach({ m in
                            let url = (m as! URL)
                            if(self.organizeScreenShotFile(url: (url))) {
                                manageFileURLS.add(url)
                            } else {
                                errors = true
                            }
                        })
                    }
                }
                
                if(manageFileRAW.count > 0) {
                    if(self.checkFolderAndCreate(folderPath: self.appDelegate.fileBrowserViewController.rawFolder)) {
                        manageFileRAW.forEach({ m in
                            let url = (m as! URL)
                            if(self.organizeRawFile(url: (url))) {
                                manageFileURLS.add(url)
                            }else {
                                errors = true
                            }
                        })
                    }
                }
                
                DispatchQueue.main.async {
                    self.fileOperationComplete(manageFileURLS: manageFileURLS, errors: errors)
                }
                
            }
            
        } else {
            //showNotification(messageType: "OrganizeFiles", customMessage: "No Files Selected!")
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
        }
    }
    
    func organizeMovieFile(url: URL) -> Bool {
        print("Organizing MOVIE ... \(url)")
        
        // let url = NSURL(fileURLWithPath: urlPath)
        let _extension = url.pathExtension

        
        let increment =  getFileIncrementAtPath(path: self.appDelegate.fileBrowserViewController.videoFolder)
        
        var newMovieFile = self.appDelegate.fileBrowserViewController.videoFolder + "/" + self.appDelegate.fileBrowserViewController.fileSequenceName + " - " + increment + "." + _extension
        
        
        //  ".MOV" // for now
        
        newMovieFile = newMovieFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newMovieFile)!)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
        
    }
    
    func organizeJPGFile(url: URL) -> Bool  {
        print("Organizing JPG ... \(url)")
        
        // let url = NSURL(fileURLWithPath: urlPath)
        let _extension = url.pathExtension

        let increment =  getFileIncrementAtPath(path: self.appDelegate.fileBrowserViewController.jpgFolder)
        
        var newJPGFile = self.appDelegate.fileBrowserViewController.jpgFolder + "/" + self.appDelegate.fileBrowserViewController.fileSequenceName + " - " + increment + "." + _extension
        
        newJPGFile = newJPGFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newJPGFile)!)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
        
    }
    
    func organizeScreenShotFile(url: URL) -> Bool {
        print("Organizing Screenshot ... \(url)")
        
        let _extension = url.pathExtension

        let increment =  getFileIncrementAtPath(path: self.appDelegate.fileBrowserViewController.screenShotFolder)
        
        var newScreenshotFile = self.appDelegate.fileBrowserViewController.screenShotFolder + "/" + self.appDelegate.fileBrowserViewController.fileSequenceName + " - " + increment + "." + _extension
        
        newScreenshotFile = newScreenshotFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newScreenshotFile)!)) {
            print("Succes... file moved");
            return true
        } else {
            print("File Move Failed")
            return false
        }
        
    }
    
    func organizeRawFile(url: URL) -> Bool {
        print("Organizing RAW ... \(url)")
        
        let _extension = url.pathExtension

        let increment =  getFileIncrementAtPath(path: self.appDelegate.fileBrowserViewController.rawFolder)
        
        var newRawFile = self.appDelegate.fileBrowserViewController.rawFolder + "/" + self.appDelegate.fileBrowserViewController.fileSequenceName + " - " + increment + "." + _extension
        
        newRawFile = newRawFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newRawFile)!)) {
            print("Succes... file moved")
            return true
        } else {
            print("File Move Failed")
            return false
        }
        
    }
    
    
    func organizeOtherFile(url: URL) -> Bool {
        print("Organizing Other ... \(url)")
        return false
    }
    
    func moveFile(from: URL, toUrl: URL) -> Bool {
        // print ("Moving file : \(from) to \(toUrl)")
        
        do {
            try FileManager.default.moveItem(at: from, to: toUrl)
            return true
        }
        catch let error as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: \(error)")
            DispatchQueue.main.async {
                self.showAlert(text: "Could not move file", body:("This file " + from.absoluteString + " could not be moved"), showCancel: false, messageType: "warning")
            }
            return false
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
    
    func getFileIncrementAtPath(path: String) -> String {
        var incrementer = "00"
        let Urlpath = path
        let path = getPathFromURL(path: path)
        
        if FileManager.default.fileExists(atPath: path) {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: Urlpath)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%04d", files.count)
                
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
    
    
    func setOpenPath1() {
        doOpenFinder(urlString:self.appDelegate.fileBrowserViewController.projectFolder)
    }
    
    func setOpenPath2() {
        doOpenFinder(urlString:self.appDelegate.fileBrowserViewController.videoFolder)
    }
    
    func setOpenPath3() {
        doOpenFinder(urlString:self.appDelegate.fileBrowserViewController.jpgFolder)
    }
    
    func setOpenPath4() {
        doOpenFinder(urlString:self.appDelegate.fileBrowserViewController.screenShotFolder)
    }
    
    func setOpenPath5() {
        doOpenFinder(urlString:self.appDelegate.fileBrowserViewController.rawFolder)
    }
    
    func doOpenFinder(urlString: String) {
        let path = pathOutputFromURL(inputString: urlString)
        
        if FileManager.default.fileExists(atPath: path) {
            let url = URL(string: urlString)!
            
            NSWorkspace.shared().open(url)
        } else {
            DispatchQueue.main.async {
                self.showAlert(text: "That Folder Doesn't Exist", body: "Select a folder and try again.", showCancel: false, messageType: "warning")
            }
        }
    }
    
    @IBAction func shareMultipleFiles(sender: AnyObject?) {
            self.appDelegate.fileManagerViewController.shareMultipleFiles(receivedFiles: self.receivedFiles as! Array<Any>, s: sender)
    }
    
}
