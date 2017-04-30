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
    
    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var chooseCopyDestinationButton1: NSButton!
    @IBOutlet var copyDirectoryLabel1: NSTextField!
    
    @IBOutlet var chooseCopyDestination2Button: NSButton!
    @IBOutlet var copyDirectoryLabel2: NSTextField!
    
    @IBOutlet var chooseCopyDestination3Button: NSButton!
    @IBOutlet var copyDirectoryLabel3: NSTextField!
    
    @IBOutlet var chooseCopyDestination4Button: NSButton!
    @IBOutlet var copyDirectoryLabel4: NSTextField!
    
    @IBOutlet var chooseCopyDestination5Button: NSButton!
    @IBOutlet var copyDirectoryLabel5: NSTextField!
    
    
    @IBOutlet var fileSizesLabel: NSTextField!
    
    var copyToFolder1 = "/Volumes/"
    var copyToFolder2 = "/Volumes/"
    var copyToFolder3 = "/Volumes/"
    var copyToFolder4 = "/Volumes/"
    var copyToFolder5 = "/Volumes/"
    
    var viewIsLoaded = false
    
    var receivedFiles = NSMutableArray() {
        didSet {
            //  print("Received Files on COPY Controller \(receivedFiles)")
            if(self.viewIsLoaded) {
                let count = String(format: "%", receivedFiles.count)
                self.numberofFilesLabel.title = count
                
                print("Calculating Sizes")
                self.updateFileSizeLabel()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("FileManagerOptionsCopyController loaded")
        
        // Folders
        
        // 1
        if(UserDefaults.standard.value(forKey: "copyToFolder1") == nil) {
            self.copyToFolder1 = self.appDelegate.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder1, forKey: "copyToFolder1")
        } else {
            self.copyToFolder1 = UserDefaults.standard.value(forKey: "copyToFolder1") as! String
        }
        
        self.copyDirectoryLabel1.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder1)
        
        // 2
        if(UserDefaults.standard.value(forKey: "copyToFolder2") == nil) {
            self.copyToFolder2 = self.appDelegate.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder2, forKey: "copyToFolder2")
        } else {
            self.copyToFolder2 = UserDefaults.standard.value(forKey: "copyToFolder2") as! String
        }
        
        self.copyDirectoryLabel2.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder2)
        
        // 3
        if(UserDefaults.standard.value(forKey: "copyToFolder3") == nil) {
            self.copyToFolder3 = self.appDelegate.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder1, forKey: "copyToFolder3")
        } else {
            self.copyToFolder3 = UserDefaults.standard.value(forKey: "copyToFolder3") as! String
        }
        
        self.copyDirectoryLabel3.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder3)
        
        // 4
        if(UserDefaults.standard.value(forKey: "copyToFolder4") == nil) {
            self.copyToFolder4 = self.appDelegate.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder4, forKey: "copyToFolder4")
        } else {
            self.copyToFolder4 = UserDefaults.standard.value(forKey: "copyToFolder4") as! String
        }
        
        // 5
        
        self.copyDirectoryLabel4.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder4)
        
        if(UserDefaults.standard.value(forKey: "copyToFolder5") == nil) {
            self.copyToFolder5 = self.appDelegate.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder5, forKey: "copyToFolder5")
        } else {
            self.copyToFolder5 = UserDefaults.standard.value(forKey: "copyToFolder5") as! String
        }
        
        self.copyDirectoryLabel5.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder5)

        // Click Gestures
        
        let tapGestureCopyFolder1 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath1))
        
        
        self.copyDirectoryLabel1.addGestureRecognizer(tapGestureCopyFolder1)
        
        let tapGestureCopyFolder2 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath2))
        
        self.copyDirectoryLabel2.addGestureRecognizer(tapGestureCopyFolder2)
    
        let tapGestureCopyFolder3 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath3))
        
        self.copyDirectoryLabel3.addGestureRecognizer(tapGestureCopyFolder3)
        
        let tapGestureCopyFolder4 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath4))
        
        self.copyDirectoryLabel4.addGestureRecognizer(tapGestureCopyFolder4)
        
        let tapGestureCopyFolder5 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath5))
        
        self.copyDirectoryLabel5.addGestureRecognizer(tapGestureCopyFolder5)
        self.updateFileSizeLabel()
        
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
    
    
    
    func updateFileSizeLabel() {
        
        
        let size = self.appDelegate.fileManagerOptionsTabViewController?.fileSizes["totalSize"] as! Int
        let files =  self.appDelegate.fileManagerOptionsTabViewController?.fileSizes["totalFiles"] as! Int
        
        //let totalSize = String(format: "%1d", fileSize)
        let totalFiles = String(format: "%1d", files)
        self.fileSizesLabel.stringValue = "Total Size: " + self.appDelegate.fileManagerViewController.bytesToHuman(size: Int64(size)) + " - Total Files: " + totalFiles + " Files"
        
    }
    
    func pathOutputFromURL(inputString: String) -> String {
        let str = inputString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        return str
    }
    
    @IBAction func chooseCopyDestinationFolder1(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                //print(openPanel.urls)
                
                self.copyToFolder1 = (openPanel.url?.absoluteString)!
                
                UserDefaults.standard.setValue(self.copyToFolder1, forKey: "copyToFolder1")
                
                self.copyDirectoryLabel1.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
                
            }
        })
    }
    
    
    @IBAction func chooseCopyDestinationFolder2(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                //print(openPanel.urls)
                
                self.copyToFolder2 = (openPanel.url?.absoluteString)!
                
                UserDefaults.standard.setValue(self.copyToFolder2, forKey: "copyToFolder2")
                
                self.copyDirectoryLabel2.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
                
            }
        })
    }
    
    
    @IBAction func chooseCopyDestinationFolder3(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                //print(openPanel.urls)
                
                self.copyToFolder3 = (openPanel.url?.absoluteString)!
                
                UserDefaults.standard.setValue(self.copyToFolder3, forKey: "copyToFolder3")
                
                self.copyDirectoryLabel3.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
                
            }
        })
    }
    
    
    @IBAction func chooseCopyDestinationFolder4(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                //print(openPanel.urls)
                
                self.copyToFolder4 = (openPanel.url?.absoluteString)!
                
                UserDefaults.standard.setValue(self.copyToFolder4, forKey: "copyToFolder4")
                
                self.copyDirectoryLabel4.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
                
            }
        })
    }
    
    
    @IBAction func chooseCopyDestinationFolder5(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                //print(openPanel.urls)
                
                self.copyToFolder5 = (openPanel.url?.absoluteString)!
                
                UserDefaults.standard.setValue(self.copyToFolder5, forKey: "copyToFolder5")
                
                self.copyDirectoryLabel5.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
                
            }
        })
    }
    
    
    func fileOperationComplete(manageFileURLS: NSMutableArray, errors: Bool) {
        
        print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fileOperationComplete")
        
        self.appDelegate.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)
        
        self.appDelegate.fileBrowserViewController?.reloadFilesWithSelected(fileName: "")
        
        // self.dismissViewController(self.appDelegate.fileCopyProgressView);
        // self.appDelegate.fileCopyProgressView.progress = 100.0
        
        if(!errors) {
            //showAlert(text: "Files Copied!", body: "The files have been copied!", showCancel: false, messageType: "notice")
        }
        
    }
    
    
    @IBAction func copyFilesFolder1(_ sender: AnyObject) {
        let filesToCopy = self.receivedFiles
        prepareToCopy(filesToCopy: filesToCopy as! Array<Any>, copyFolder: self.copyToFolder1)
    }
    

    @IBAction func copyFilesFolder2(_ sender: AnyObject) {
        let filesToCopy = self.receivedFiles
        prepareToCopy(filesToCopy: filesToCopy as! Array<Any>, copyFolder: self.copyToFolder2)
    }
    

    @IBAction func copyFilesFolder3(_ sender: AnyObject) {
        let filesToCopy = self.receivedFiles
        prepareToCopy(filesToCopy: filesToCopy as! Array<Any>, copyFolder: self.copyToFolder3)
    }
    
    
    @IBAction func copyFilesFolder4(_ sender: AnyObject) {
        let filesToCopy = self.receivedFiles
        prepareToCopy(filesToCopy: filesToCopy as! Array<Any>, copyFolder: self.copyToFolder4)
    }

    
    @IBAction func copyFilesFolder5(_ sender: AnyObject) {
        let filesToCopy = self.receivedFiles
        prepareToCopy(filesToCopy: filesToCopy as! Array<Any>, copyFolder: self.copyToFolder5)
    }
    
    func prepareToCopy(filesToCopy: Array<Any>, copyFolder: String) {
    
        
        let manageFileURLS: NSMutableArray = []
        let fileUrls = filesToCopy
        
        if(fileUrls.count > 0) {
            
            self.appDelegate.fileCopyProgressView.totalNumfilesTransferred = 0
            
            self.appDelegate.fileCopyProgressView.currentFileNumber = 0
            self.appDelegate.fileCopyProgressView.bytesTransferred = 0
            
            let fileSizes = self.appDelegate.fileManagerViewController?.calculateFileSizesFromDestination(fileUrls: fileUrls)
            
            self.appDelegate.fileCopyProgressView.destinationSize = fileSizes?["totalSize"] as! Int64
            
            self.appDelegate.fileCopyProgressView.totalNumfiles = fileSizes?["totalFiles"] as! Int
            
            self.presentViewControllerAsModalWindow(self.appDelegate.fileCopyProgressView)
            
            var errors = false
            
            DispatchQueue.global(qos: .userInitiated).async {
                var b = Int(1)
                
                fileUrls.forEach({ m in
                    let urlPath = m as! String
                    let url = URL(string: urlPath)
                    self.appDelegate.fileCopyProgressView.currentFileNumber += Int(1)
                    
                    if(self.copyFileFolder1(url: url!, destination: copyFolder)) {
                        manageFileURLS.add(url!)
                        self.appDelegate.fileCopyProgressView.totalNumfilesTransferred += Int(1)
                    } else {
                        errors = true
                        self.appDelegate.fileCopyProgressView.totalNumfilesTransferred += Int(1)
                    }
                    
                    b += Int(1)
                    if(b == fileUrls.count) {
                        DispatchQueue.main.async {
                            self.fileOperationComplete(manageFileURLS: manageFileURLS, errors: errors)
                        }
                    }
                })
                
            }
            
        } else {
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
        }

        
    
    }
    
    
    func copyFileFolder1(url: URL, destination:String) -> Bool {
        // print("Copying File! ... \(url)")
        
        // let tmpURL = NSURL(fileURLWithPath: url.absoluteString)
        let fileName = url.lastPathComponent
        
        // print("Copy FROM filename: \(fileName)")
        
        var copyDestination = ""
        copyDestination = destination + fileName
        
        //  copyDestination = getPathFromURL(path: copyDestination)
        copyDestination = copyDestination.replacingOccurrences(of: " ", with: "%20")
        
        // print("Copy DESTINATION: \(copyDestination)")
        
        
        let destinationURL = URL(string: copyDestination)!
        // let urlPath = getPathFromURL(path: destinationURL.absoluteString)
        
        self.appDelegate.fileCopyProgressView.pauseTimer = true
        self.appDelegate.fileCopyProgressView.destinationCurrentFile = destinationURL.absoluteString

        
        if !FileManager.default.fileExists(atPath: getPathFromURL(path: copyDestination)) {
            
            self.appDelegate.fileCopyProgressView.destinationCurrentFileSize = Int64(0)
            self.appDelegate.fileCopyProgressView.pauseTimer = false
            if(self.doCopyFile(from: url, toUrl: destinationURL)) {
                print("Succes... file copied")
                return true
            } else {
                print("File Copy Failed")
                return false
            }
            
        } else {
            
            let foo = self.appDelegate.fileManagerViewController?.calculateSingleFileSize(fileUrl: destinationURL.absoluteString)
            self.appDelegate.fileCopyProgressView.destinationCurrentFileSize = Int64(0)
            self.appDelegate.fileCopyProgressView.bytesTransferred += foo?["totalSize"] as! Int64
            self.appDelegate.fileCopyProgressView.pauseTimer = false
            return true
        }
    }
    

    
    func doCopyFile(from: URL, toUrl: URL) -> Bool {
        
        
        do {
            try FileManager.default.copyItem(at: from, to: toUrl)
            return true
        }
        catch _ as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: ")
            showAlert(text: "Could not copy file", body:("This file " + from.absoluteString + " could not be copied"), showCancel: false, messageType: "warning")
            
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
        doOpenFinder(urlString:self.copyToFolder1)
        
    }
    
    func setOpenPath2() {
        doOpenFinder(urlString:self.copyToFolder2)
    }
    
    func setOpenPath3() {
        doOpenFinder(urlString:self.copyToFolder3)
    }
    
    func setOpenPath4() {
        doOpenFinder(urlString:self.copyToFolder4)
    }
    
    func setOpenPath5() {
        doOpenFinder(urlString:self.copyToFolder5)
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
