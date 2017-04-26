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
    
    
    @IBOutlet var numberofFilesLabel: NSTextField!
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
                let count = String(format: "%2d", receivedFiles.count)
                self.numberofFilesLabel.stringValue = "(" + count  + ")"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("FileManagerOptionsCopyController loaded")
        
        
        
        // Folders
        
        if(UserDefaults.standard.value(forKey: "copyToFolder1") == nil) {
            self.copyToFolder1 = self.fileManagerOptionsTabViewController.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder1, forKey: "copyToFolder1")
        } else {
            self.copyToFolder1 = UserDefaults.standard.value(forKey: "copyToFolder1") as! String
        }
    
        self.copyDirectoryLabel1.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder1)
        
        
        
        
        
        if(UserDefaults.standard.value(forKey: "copyToFolder2") == nil) {
            self.copyToFolder2 = self.fileManagerOptionsTabViewController.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder2, forKey: "copyToFolder2")
        } else {
            self.copyToFolder2 = UserDefaults.standard.value(forKey: "copyToFolder2") as! String
        }
        
        self.copyDirectoryLabel2.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder2)
        
        
        
        
        
        if(UserDefaults.standard.value(forKey: "copyToFolder3") == nil) {
            self.copyToFolder3 = self.fileManagerOptionsTabViewController.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder1, forKey: "copyToFolder3")
        } else {
            self.copyToFolder3 = UserDefaults.standard.value(forKey: "copyToFolder3") as! String
        }
        
        self.copyDirectoryLabel3.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder3)
        
        
        
        
        
        if(UserDefaults.standard.value(forKey: "copyToFolder4") == nil) {
            self.copyToFolder4 = self.fileManagerOptionsTabViewController.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder4, forKey: "copyToFolder4")
        } else {
            self.copyToFolder4 = UserDefaults.standard.value(forKey: "copyToFolder4") as! String
        }
        
        self.copyDirectoryLabel4.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder4)
        
        if(UserDefaults.standard.value(forKey: "copyToFolder5") == nil) {
            self.copyToFolder5 = self.fileManagerOptionsTabViewController.fileBrowserViewController.outputDirectory
            UserDefaults.standard.setValue(self.copyToFolder5, forKey: "copyToFolder5")
        } else {
            self.copyToFolder5 = UserDefaults.standard.value(forKey: "copyToFolder5") as! String
        }
        
        self.copyDirectoryLabel5.stringValue = self.urlStringToDisplayPath(input: self.copyToFolder5)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.stringValue = "(" + count  + ")"
    }
    
    override func viewDidDisappear() {
        self.viewIsLoaded = false
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
    
    
    
    @IBAction func copyFiles(_ sender: AnyObject) {
        let manageFileURLS: NSMutableArray = []
        let fileUrls = self.receivedFiles as! Array<Any>
        
        if(fileUrls.count > 0) {
            fileUrls.forEach({ m in
                
                let urlPath = m as! String
                let url = URL(string: urlPath)
                
                if(self.copyFile(url: url!)) {
                    manageFileURLS.add(url!)
                }
                
            })
            
            self.fileManagerOptionsTabViewController?.fileManagerViewController?.resetTableAfterFileOperation(fileArray: manageFileURLS)

            showAlert(text: "Files Copied!", body: "The files have been copied!", showCancel: false, messageType: "warning")
    
        } else {
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
        }
    }
    
    func copyFile(url: URL) -> Bool {
        print("Copying File! ... \(url)")
        
        // let tmpURL = NSURL(fileURLWithPath: url.absoluteString)
        let fileName = url.lastPathComponent
        
        print("Copy FROM filename: \(fileName)")
        
        var copyDestination = ""
        copyDestination = self.copyToFolder1 + fileName
        
        //  copyDestination = getPathFromURL(path: copyDestination)
        copyDestination = copyDestination.replacingOccurrences(of: " ", with: "%20")
        
        print("Copy DESTINATION: \(copyDestination)")
        
        
        let destinationURL = URL(string: copyDestination)!
        
        if(self.doCopyFile(from: url, toUrl: destinationURL)) {
            print("Succes... file copied")
            return true
        } else {
            print("File Copy Failed")
            return false
        }
    }
    
    func doCopyFile(from: URL, toUrl: URL) -> Bool {
        
        print("FROM: \(from)")
        print("TO: \(toUrl)")
        
        do {
            try FileManager.default.copyItem(at: from, to: toUrl)
            return true
        }
        catch _ as NSError {
            // print ("Error while moving file : \(from) to \(toUrl)")
            print("Ooops! Something went wrong: ")
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
    
    func urlStringToDisplayURLString(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    func urlStringToDisplayPath(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    
}
