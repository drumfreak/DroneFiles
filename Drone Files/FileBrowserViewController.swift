//
//  ViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation


class FileBrowserViewController: NSViewController {
    // View controllers
    @IBOutlet var topView: NSView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var projectDirectoryLabel: NSTextField!
    
    @IBOutlet var backgroundImage: NSImageView!
    // Directories!
    var directory: Directory?
    
    var sourceFolderOpened: Any? {
        didSet {
            if let url = sourceFolderOpened as? URL {
                // print("Source Folder Opened: \(url)")
                directory = Directory(folderURL: url)
                self.reloadFileList()
                self.currentDir = url
                self.appDelegate.appSettings.folderURL = url.absoluteString
                // self.folderURLDisplay.stringValue = self.urlStringToDisplayPath(input: self.folderURL)
                self.currentFolderPathControl.url = URL(string: self.appDelegate.appSettings.folderURL)
                UserDefaults.standard.setValue(self.appDelegate.appSettings.folderURL, forKey: "sourceDirectory")
            }
        }
    }
    
    
    // URL
    var startingDirectory: URL!
    
    var currentDir: URL!
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    
    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet weak var fileSequenceNameTextField: NSTextField!
    @IBOutlet weak var folderURLDisplay: NSTextField!
    @IBOutlet var outputDirectoryLabel: NSTextField!
    @IBOutlet var createProjectDirectoryButton: NSButton!
    @IBOutlet var createProjectSubDirectoriesButton: NSButton!
    
    @IBOutlet var sequenceNameSetButton: NSButton!
    let sizeFormatter = ByteCountFormatter()
    
    @IBOutlet var fileBrowserHomeButton: NSButton!
    
    
    var selectedFileURLS: NSMutableArray = []
    
    @IBOutlet var videosDirectoryLabel: NSTextField!
    @IBOutlet var jpgDirectoryLabel: NSTextField!
    @IBOutlet var rawDirectoryLabel: NSTextField!
    @IBOutlet var screenshotDirectoryLabel: NSTextField!
    @IBOutlet var videoClipsDirectoryLabel: NSTextField!
    
    @IBOutlet var currentFolderPathControl: NSPathControl!
    @IBOutlet var videosFolderPathControl: NSPathControl!
    @IBOutlet var clipsFolderPathControl: NSPathControl!
    @IBOutlet var framesFolderPathControl: NSPathControl!
    @IBOutlet var jpgFolderPathControl: NSPathControl!
    @IBOutlet var rawFolderPathControl: NSPathControl!
    
    // Tableviews - File List
    @IBOutlet var tableView: NSTableView!
    var sortOrder = Directory.FileOrder.Name
    var sortAscending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd-YYYY"
        let now = dateformatter.string(from: NSDate() as Date)
        
        self.appDelegate.appSettings.fileSequenceName = now + " - " + self.appDelegate.appSettings.fileSequenceNameTag
        
        let defaults = UserDefaults.standard
        
        if(defaults.value(forKey: "sourceDirectory") == nil) {
            defaults.setValue("file:///Volumes/", forKey: "sourceDirectory")
            defaults.setValue("file:///Volumes/", forKey: "outputDirectory")
            defaults.setValue("My Project", forKey: "fileSequenceNameTag")
            defaults.setValue(1, forKey: "createProjectDirectory")
            defaults.setValue(1, forKey: "createProjectSubDirectories")
            defaults.setValue(1, forKey: "createProjectDirectory")
            defaults.setValue(1, forKey: "createProjectSubDirectories")
        }
        
        self.appDelegate.appSettings.sourceFolder = defaults.value(forKey: "sourceDirectory") as! String
        self.appDelegate.appSettings.outputDirectory = defaults.value(forKey: "outputDirectory") as! String
        self.appDelegate.appSettings.fileSequenceNameTag = defaults.value(forKey: "fileSequenceNameTag") as! String
        self.startingDirectory = URL(string: self.appDelegate.appSettings.sourceFolder)
        self.sourceFolderOpened = self.startingDirectory
        self.appDelegate.appSettings.fileSequenceName = self.appDelegate.appSettings.fileSequenceNameTag
        
        
        self.createProjectSubDirectoriesButton.state = (defaults.value(forKey: "createProjectSubDirectories") as! Int)
        self.createProjectDirectoryButton.state = (defaults.value(forKey: "createProjectDirectory") as! Int)
        
        if(self.createProjectSubDirectoriesButton.state == 0) {
            self.appDelegate.appSettings.createProjectSubDirectories = false
        }
        
        if(self.createProjectDirectoryButton.state == 0) {
            self.appDelegate.appSettings.createProjectDirectory = false
        }
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.statusLabel.stringValue = "0 Items Selected"
        self.tableView.target = self
        self.tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        
        // Add a background view to the table view
        self.tableView.backgroundColor = self.appDelegate.appSettings.appViewBackgroundColor
        
        self.fileSequenceNameTextField.stringValue = self.appDelegate.appSettings.fileSequenceName
        
        self.appDelegate.appSettings.saveDirectoryName = self.appDelegate.appSettings.fileSequenceName
        
        //videoView.
        self.showNotification(messageType: "default", customMessage: "");
        
        self.currentDir = self.startingDirectory
        
        self.currentFolderPathControl.backgroundColor = NSColor.clear
        
        // self.outputDirectory = self.currentDir.absoluteString
        
        self.outputDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appDelegate.appSettings.outputDirectory)
        
        setupProjectDirectory()
        
        let descriptorName = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
        let descriptorDate = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: true)
        let descriptorSize = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)
        
        self.tableView.tableColumns[0].sortDescriptorPrototype = descriptorName
        self.tableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
        self.tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
        
        self.sourceFolderOpened = self.startingDirectory
        self.appDelegate.appSettings.folderURL = self.startingDirectory?.absoluteString
        
        // self.folderURLDisplay.stringValue = urlStringToDisplayPath(input:self.folderURL)
        
        reloadFileList()
        
        self.appDelegate.fileBrowserViewController = self
        
    }
    
    
    
    func setOpenPath1() {
        // self.sourceFolderOpened =  URL(string: self.sourceFolderOpened.absoluteString)
        
    }
    
    
    func setOpenPath2() {
        self.sourceFolderOpened = URL(string: self.appDelegate.appSettings.outputDirectory)
    }
    
    @IBAction func fileBrowserHomeButtonClicked(_ sender: AnyObject?) {
        // print ("Clicked home button")
        
        let paths = getPathsFromURL(url: self.currentDir)
        
        // print("Paths: \(paths)")
        let tmp = paths["paths"] as! NSArray
        var counter = Int(0)
        
        let previousIndex = paths["parentIndex"] as! Int
        
        // print("previousIndex \(String(describing: previousIndex))")
        self.appDelegate.appSettings.previousUrlString = "file://"
        
        tmp.forEach { thisPath in
            print(thisPath)
            if(counter <= previousIndex) {
                self.appDelegate.appSettings.previousUrlString = self.appDelegate.appSettings.previousUrlString + "/" + (thisPath as! String)
            }
            
            if(counter == previousIndex) {
                // print("SHOULD OPEN " + self.previousUrlString)
                
                self.sourceFolderOpened = URL(string: self.appDelegate.appSettings.previousUrlString)
                reloadFileList()
            }
            counter = counter + Int(1)
        }
    }
    
    func getPathsFromURL(url: URL!) -> NSMutableDictionary {
        let startingDir = url.absoluteString.replacingOccurrences(of: "file:///", with: "")
        // startingDir = String(startingDir.characters.dropLast())
        
        let truncated = startingDir.substring(to: startingDir.index(before: startingDir.endIndex))
        
        var pathsArray = truncated.components(separatedBy: "/")
        
        let arrayCount = pathsArray.count
        
        let previousElement = arrayCount - Int(2),
        currentElement = arrayCount - Int(1)
        
        let currentPath = pathsArray[currentElement]
        
        var keyArray = NSMutableArray(), objectArray = NSMutableArray()
        keyArray = ["paths","currentPath", "currentIndex", "rootPath", "parentDirectory", "parentIndex"]
        
        let parentDirectory = pathsArray[previousElement]
        objectArray = [pathsArray, currentPath, currentElement, "Volumes", parentDirectory, previousElement] as [Any] as! NSMutableArray
        
        let dictionary = NSMutableDictionary(objects: objectArray as! [Any], forKeys: keyArray as! [NSCopying])
        return dictionary
    }
    
    // Open directory for tableview
    @IBAction func openDocument(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        openPanel.resolvesAliases = true
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                self.sourceFolderOpened = openPanel.url
                self.appDelegate.appSettings.sourceFolder = (openPanel.url?.absoluteString)!
                self.startingDirectory = openPanel.url
                self.appDelegate.appSettings.sourceFolder = (openPanel.url?.absoluteString)!
                
                UserDefaults.standard.setValue(self.appDelegate.appSettings.sourceFolder, forKey: "sourceDirectory")
                //self.folderURLDisplay.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
                self.setupProjectDirectory()
                
            }
        })
    }
    
    
    // Open directory for tableview
    @IBAction func chooseOutputDirectory(_ sender: AnyObject?) {
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = false
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = true
        openPanel.resolvesAliases = true
        
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                self.appDelegate.appSettings.outputDirectory = (openPanel.url?.absoluteString)!
                self.outputDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appDelegate.appSettings.outputDirectory)
                UserDefaults.standard.setValue(self.appDelegate.appSettings.outputDirectory, forKey: "outputDirectory")
                self.setupProjectDirectory()
            }
            
        })
    }
    
    
    
    
    // Open directory for tableview
    @IBAction func openProjectFile(_ sender: AnyObject?) {
        
        let openPanel = NSOpenPanel()
        openPanel.showsHiddenFiles = true
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.resolvesAliases = true
        
        openPanel.begin(completionHandler: {(result:Int) in
            if(result == NSFileHandlingPanelOKButton) {
                print("Path Extension \(String(describing: openPanel.url?.pathExtension))")
                
                if(openPanel.url?.pathExtension == "dronefiles") {
                    print ("HEY it's drone files!")
                    self.readProjectFile(projectFile: (openPanel.url?.absoluteString)!)
                    
                    //                    self.appDelegate.documentController.openDocument(withContentsOf: openPanel.url!, display: true, completionHandler: { (document: NSDocument?, wasOpen: Bool, err: Error?) in
                    //                        print("Fuck yeah \(String(describing: document))")
                    //                        print("Error: \(String(describing: err))")
                    //                    })
                    
                }
            }
            
        })
    }
    
    
    
    @IBAction func createProjectDirectoryCheckbox(_ sender: AnyObject?) {
        self.appDelegate.appSettings.createProjectDirectory = !self.appDelegate.appSettings.createProjectDirectory
        if(self.appDelegate.appSettings.createProjectDirectory) {
            UserDefaults.standard.setValue(1, forKey: "createProjectDirectory")
        } else {
            UserDefaults.standard.setValue(0, forKey: "createProjectDirectory")
        }
        
        self.setupProjectDirectory()
        
        
    }
    
    @IBAction func createProjectSubDirectoriesCheckbox(_ sender: AnyObject?) {
        self.appDelegate.appSettings.createProjectSubDirectories = !self.appDelegate.appSettings.createProjectSubDirectories
        if(self.appDelegate.appSettings.createProjectSubDirectories) {
            UserDefaults.standard.setValue(1, forKey: "createProjectSubDirectories")
        } else {
            UserDefaults.standard.setValue(0, forKey: "createProjectSubDirectories")
        }
        self.setupProjectDirectory()
    }
    
    // Helper Functions
    func setupProjectDirectory() {
        self.appDelegate.appSettings.saveDirectoryName =  self.appDelegate.appSettings.fileSequenceName
        self.appDelegate.appSettings.projectFolder = self.appDelegate.appSettings.outputDirectory + self.appDelegate.appSettings.saveDirectoryName
        
        if(self.appDelegate.appSettings.createProjectDirectory) {
            self.appDelegate.appSettings.projectFolder = self.appDelegate.appSettings.outputDirectory + self.appDelegate.appSettings.saveDirectoryName
        } else {
            self.appDelegate.appSettings.projectFolder = self.appDelegate.appSettings.outputDirectory
        }
        
        self.appDelegate.appSettings.projectDirectory = urlStringToDisplayPath(input: self.appDelegate.appSettings.projectFolder)
        self.projectDirectoryLabel.stringValue = self.appDelegate.appSettings.projectDirectory
        
        if(self.appDelegate.appSettings.createProjectSubDirectories) {
            self.appDelegate.appSettings.videoFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - Videos"
            self.appDelegate.appSettings.videoClipsFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - Video Clips"
            self.appDelegate.appSettings.jpgFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - JPG"
            self.appDelegate.appSettings.screenShotFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - Frames"
            self.appDelegate.appSettings.rawFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - RAW"
            self.appDelegate.appSettings.dngFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - RAW"
        } else {
            self.appDelegate.appSettings.videoFolder = self.appDelegate.appSettings.projectFolder + "/"
            self.appDelegate.appSettings.videoClipsFolder = self.appDelegate.appSettings.projectFolder  + "/"
            self.appDelegate.appSettings.jpgFolder = self.appDelegate.appSettings.projectFolder  + "/"
            self.appDelegate.appSettings.screenShotFolder = self.appDelegate.appSettings.projectFolder  + "/"
            self.appDelegate.appSettings.rawFolder = self.appDelegate.appSettings.projectFolder  + "/"
            self.appDelegate.appSettings.dngFolder = self.appDelegate.appSettings.projectFolder  + "/"
        }
        
        self.appDelegate.appSettings.projectFolder = self.appDelegate.appSettings.projectFolder.replacingOccurrences(of: " ", with: "%20")
        self.appDelegate.appSettings.videoFolder = self.appDelegate.appSettings.videoFolder.replacingOccurrences(of: " ", with: "%20")
        self.appDelegate.appSettings.videoClipsFolder = self.appDelegate.appSettings.videoClipsFolder.replacingOccurrences(of: " ", with: "%20")
        self.appDelegate.appSettings.jpgFolder = self.appDelegate.appSettings.jpgFolder.replacingOccurrences(of: " ", with: "%20")
        self.appDelegate.appSettings.screenShotFolder = self.appDelegate.appSettings.screenShotFolder.replacingOccurrences(of: " ", with: "%20")
        self.appDelegate.appSettings.rawFolder = self.appDelegate.appSettings.rawFolder.replacingOccurrences(of: " ", with: "%20")
        self.appDelegate.appSettings.dngFolder = self.appDelegate.appSettings.dngFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.fileManagerOptionsOrganizeController?.setupProjectPaths()
        
        // let projectPath = pathOutputFromURL(inputString: self.projectFolder)
        
        self.videosFolderPathControl.url = URL(string:self.appDelegate.appSettings.videoFolder)
        self.clipsFolderPathControl.url = URL(string:self.appDelegate.appSettings.videoClipsFolder)
        self.framesFolderPathControl.url = URL(string:self.appDelegate.appSettings.screenShotFolder)
        self.jpgFolderPathControl.url = URL(string:self.appDelegate.appSettings.jpgFolder)
        self.rawFolderPathControl.url = URL(string:self.appDelegate.appSettings.rawFolder)
    }
    
    
    
    func pathOutputFromURL(inputString: String) -> String {
        let str = inputString.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
        return str
    }
    
    func getPathFromURL(path: String) -> String {
        var path = path.replacingOccurrences(of: "file://", with: "")
        path = path.replacingOccurrences(of: "%20" , with: " ")
        return path
    }
    
    // Button and Input Text Actions
    @IBAction func fileSequenceLabelChanged(sender: AnyObject) {
        
    }
    
    
    @IBAction func pathControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = self.currentFolderPathControl.clickedPathItem?.url
    }
    
    @IBAction func videosPathControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = self.videosFolderPathControl.clickedPathItem?.url
    }
    
    @IBAction func clipsControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = self.clipsFolderPathControl.clickedPathItem?.url
    }
    
    
    @IBAction func framesControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = self.framesFolderPathControl.clickedPathItem?.url
    }
    
    
    @IBAction func rawControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = self.rawFolderPathControl.clickedPathItem?.url
    }
    
    
    @IBAction func jpgControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = self.jpgFolderPathControl.clickedPathItem?.url
    }
    
    @IBAction func fileSequenceNameSetButtonClicked(sender: AnyObject) {
        
        self.fileSequenceNameTextField.resignFirstResponder()
        
        self.appDelegate.appSettings.fileSequenceName = self.fileSequenceNameTextField.stringValue
        // self.newFileNamePath.stringValue = self.fileSequenceName
        print("New Sequence Name \( self.appDelegate.appSettings.fileSequenceName)")
        
        UserDefaults.standard.setValue(self.appDelegate.appSettings.fileSequenceName, forKey: "fileSequenceNameTag")
        
        self.setupProjectDirectory()
        self.writeProjectFile(projectPath: self.appDelegate.appSettings.projectFolder)
    }
    
    
    func showNotification(messageType: String, customMessage: String) -> Void {
        DispatchQueue.global(qos: .userInitiated).async {
            if(messageType == "VideoTrimComplete") {
                // DispatchQueue.main.async {
                // print("Message Type VIDEO TRIM COMPLETE: " + messageType);
                let notification = NSUserNotification()
                notification.title = "Video Trimming Complete"
                notification.informativeText = "Your clip has been saved. " + customMessage.replacingOccurrences(of: "%20", with: " ")
                
                notification.soundName = NSUserNotificationDefaultSoundName
                // NSUserNotificationCenter.default.deliver(notification)
                NSUserNotificationCenter.default.deliver(notification);
                // }
            }
            
            if(messageType == "default") {
                // DispatchQueue.main.async {
                
                // print("Message Type Welcome: " + messageType);
                let notification = NSUserNotification()
                notification.title = "Welcome to DroneFiles!"
                notification.informativeText = "Your life will never be the same"
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notification)
                
                //  }
            }
        }
    }
    
    
    func reloadFilesWithSelected(fileName: String) {
        self.sourceFolderOpened = URL(string: self.appDelegate.appSettings.folderURL)
        let url = URL(string: fileName)
        var i = 0
        
        self.directoryItems?.forEach({ directoryItem in
            let turl = directoryItem.url
            if(turl == url) {
                print(directoryItem.url)
                print("HOLLLY FUCK")
                
                let indexSet =  NSIndexSet(index: i) as IndexSet
                self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
            }
            i += Int(1)
            
        })
    }
    
    
    
    func reloadFileList() {
        directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        self.tableView.reloadData()
    }
    
    
    func loadItemFromTable() {
        
        // print("SELECTED ROW \(self.tableView.selectedRow)")
        
        // 1
        guard self.tableView.selectedRow >= 0,
            let item = directoryItems?[self.tableView.selectedRow] else {
                return
        }
        
        if item.isFolder {
            // 2
            // print("CLICKED FOLDER");
            // self.currentDir = item.url as URL
            // self.representedObject = item.url as Any
        }
        else {
            
            // print("SELECTED ITEM IS \(item)");
            // 3
            
            let url = NSURL(fileURLWithPath: item.url.absoluteString)
            
            let _extension = url.pathExtension
            
            if(_extension == "dronefiles") {
                self.readProjectFile(projectFile: item.url.absoluteString)
            }
            
            if(_extension == "MOV" || _extension == "mov" || _extension == "mp4" || _extension == "MP4" || _extension == "m4v" || _extension == "M4V") {
                
                self.appDelegate.editorTabViewController?.selectedTabViewItemIndex = 0
                
                // nowPlayingFile.stringValue = item.name;
                var itemUrl = (item.url as URL).absoluteString
                itemUrl = itemUrl.replacingOccurrences(of: "file://", with: "")
                // print("~~~~~~~~~~~~~~~~~~~~~~~ NOW PLAYING: " + itemUrl)
                
                self.appDelegate.videoPlayerViewController?.VideoEditView.isHidden = false;
                
                self.appDelegate.videoPlayerControlsController?.nowPlayingFile.stringValue = item.name
                
                self.appDelegate.videoPlayerControlsController?.currentVideoURL = item.url as URL
                
                self.appDelegate.videoPlayerViewController?.nowPlayingURL = (item.url as URL)
                
                self.appDelegate.videoPlayerControlsController?.nowPlayingURLString = itemUrl
                
                self.appDelegate.videoPlayerViewController?.playVideo(_url: item.url as URL, frame:kCMTimeZero, startPlaying: true);
                
                
            } else {
                // self.editorTabViewController.videoPlayerViewController.VideoEditView.isHidden = true;
            }
            
            if(_extension == "JPG" || _extension == "jpg" || _extension == "DNG" || _extension == "dng" || _extension == "png" || _extension == "PNG") {
                
                // HEY FUCKER YOU MUST SWITCH TABS FIRST OR THIS BREAKS!
                self.appDelegate.editorTabViewController?.selectedTabViewItemIndex = 1
                self.appDelegate.imageEditorViewController?.loadImage(_url: item.url as URL)
                
            } else {
                // self.videoPlayerViewController.VideoEditView.isHidden = true;
            }
        }
        
    }
    
    func sendItemsToFileManager (showTab: Bool) {
        self.selectedFileURLS = []
        for (_, index) in self.tableView.selectedRowIndexes.enumerated() {
            guard index >= 0,
                let item = directoryItems?[index] else {
                    return
            }
            
            // print("SELECTED ITEMS \(item.url)")
            
            selectedFileURLS.add(item.url)
            
        }
        
        if(showTab) {
            self.appDelegate.editorTabViewController?.selectedTabViewItemIndex = 2
        }
        
        self.appDelegate.fileManagerViewController?.fileURLs = self.selectedFileURLS
    }
    
    @IBAction func openSlideShow(_ sender: AnyObject?) {
        self.appDelegate.slideShowWindowController?.showWindow(self)
        print("What the fuck man...")
    }
    
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "slideShow" {
            
            print("Doing the segue....")
            
            self.appDelegate.slideShowWindowController = segue.destinationController as? SlideShowWindowController
            
            self.appDelegate.slideShowController?.loadImages(items: self.selectedFileURLS)
            
        }
    }
    
    
    func updateStatus() {
        
        let text: String
        
        // 1
        let itemsSelected = self.tableView.selectedRowIndexes.count
        
        // 2
        if (directoryItems == nil) {
            text = "No Items"
        }
        else if(itemsSelected == 0) {
            text = "\(directoryItems!.count) items"
        }
        else {
            text = "\(itemsSelected) of \(directoryItems!.count) selected"
        }
        
        // 3
        statusLabel.stringValue = text
        // print("Selected Text : \(text)");
        
        if(itemsSelected > 1) {
            self.sendItemsToFileManager(showTab: true)
        } else {
            self.sendItemsToFileManager(showTab: false)
            loadItemFromTable()
        }
    }
    
    func tableViewDoubleClick(_ sender:AnyObject) {
        //        // 1
        guard self.tableView.selectedRow >= 0,
            let item = directoryItems?[self.tableView.selectedRow] else {
                return
        }
        
        if item.isFolder {
            // 2
            //print("CLICKED FOLDER");
            self.sourceFolderOpened = item.url as Any
            self.currentDir = item.url as URL
        }
        else {
            // 3
            // NSWorkspace.shared().open(item.url as URL)
        }
    }
    
    
    // Helper Functions
    func urlStringToDisplayURLString(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    func urlStringToDisplayPath(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    
    func readProjectFile(projectFile: String) {
        let path = URL(string: projectFile)
        print("READING PRPOJECT FILE")
        do {
            let data = try Data(contentsOf: path!, options: .alwaysMapped)
            let projectJson = try? JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = projectJson as? [String: Any] {
                for (key, val) in dictionary {
                    if(key == "projectName") {
                        print("LOADED projectName: \(val)")
                        self.appDelegate.appSettings.fileSequenceName = val as! String
                        self.fileSequenceNameTextField.stringValue = self.appDelegate.appSettings.fileSequenceName
                        UserDefaults.standard.setValue(self.appDelegate.appSettings.fileSequenceName, forKey: "fileSequenceNameTag")
                        
                    }
                    
                    
                    if(key == "projectDirectory") {
                        print("projectDirectory: \(val)")
                        self.appDelegate.appSettings.projectFolder = val as! String
                        self.sourceFolderOpened = URL(string: self.appDelegate.appSettings.projectFolder)
                    }
                    
                    if(key == "outputDirectory") {
                        print("outputDirectory: \(val)")
                        self.appDelegate.appSettings.outputDirectory = val as! String
                        self.outputDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.appDelegate.appSettings.outputDirectory)
                        
                    }
                    
                    if(key == "currentDirectory") {
                        print("currentDirectory: \(val)")
                        
                    }
                    
                    if(key == "videosDirectory") {
                        print("currentDirectory: \(val)")
                        self.appDelegate.appSettings.videoFolder = val as! String
                    }
                    
                    if(key == "jpgDirectory") {
                        print("jpgDirectory: \(val)")
                        self.appDelegate.appSettings.jpgFolder = val as! String
                    }
                    
                    if(key == "rawDirectory") {
                        print("rawDirectory: \(val)")
                        self.appDelegate.appSettings.rawFolder = val as! String
                    }
                    
                    if(key == "videoClipsDirectory") {
                        print("VideoClipsDirectory: \(val)")
                        self.appDelegate.appSettings.videoClipsFolder = val as! String
                    }
                }
                
                self.setupProjectDirectory()
                
            }
            
            //  print(projectJson!)
        } catch let error {
            print(error.localizedDescription)
        }
        
        
    }
    
    func writeProjectFile (projectPath: String) {
        if(checkFolderAndCreate(folderPath: projectPath)) {
            
            print("CREATING DRONE FILES PROJECT")
            
            let documentsDirectoryPath = NSURL(string: projectPath)!
            
            let jsonFilePath = documentsDirectoryPath.appendingPathComponent(self.appDelegate.appSettings.fileSequenceName + ".dronefiles")
            
            
            // creating a .json file in the Documents folder
            
            let fileManager = FileManager.default
            
            var isDirectory: ObjCBool = false
            var foo = jsonFilePath?.absoluteString.replacingOccurrences(of: "file://", with: "")
            
            foo = foo?.replacingOccurrences(of: "%20", with: " ")
            
            if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!, isDirectory: &isDirectory) {
                let created = fileManager.createFile(atPath: foo!, contents: nil, attributes: nil)
                if created {
                    print("File created ")
                } else {
                    print("Couldn't create file for some reason")
                }
            } else {
                print("File already exists")
            }
            
            
            // creating an array of test data
            
            let dic = ["projectName" : self.appDelegate.appSettings.fileSequenceName,
                       "projectDirectory": self.appDelegate.appSettings.projectFolder,
                       "videosDirectory": self.appDelegate.appSettings.videoFolder,
                       "videoClipsDirectory": self.appDelegate.appSettings.videoClipsFolder,
                       "jpgDirectory": self.appDelegate.appSettings.jpgFolder,
                       "rawDirectory": self.appDelegate.appSettings.rawFolder,
                       "outputDirectory": self.appDelegate.appSettings.outputDirectory,
                       "currentDirectory": self.appDelegate.appSettings.folderURL,
                       ]
            
            // print(dic)
            
            print("Try this Path: \(String(describing: jsonFilePath))")
            
            var jsonData: Data!
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                
                // Write that JSON to the file created earlier
                do {
                    let file = try FileHandle.init(forWritingTo: jsonFilePath!)
                    file.write(jsonData)
                    print("JSON data was written to the file successfully!")
                    self.readProjectFile(projectFile: (jsonFilePath?.absoluteString)!)
                } catch let error as NSError {
                    print("Couldn't write to file: \(error.localizedDescription)")
                }
                
                // print("\(String(describing: jsonString))")
                
            } catch let error as NSError {
                print("Array to JSON conversion failed: \(error.localizedDescription)")
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

extension FileBrowserViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return directoryItems?.count ?? 0
    }
    
    
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        // 1
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        if let order = Directory.FileOrder(rawValue: sortDescriptor.key!) {
            // 2
            sortOrder = order
            sortAscending = sortDescriptor.ascending
            reloadFileList()
        }
    }
    
}

extension FileBrowserViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCellID"
        static let DateCell = "DateCellID"
        static let SizeCell = "SizeCellID"
        static let KindCell = "KindCellID"
    }
    

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        
        // 1
        guard let item = directoryItems?[row] else {
            return nil
        }
        
        // print(item);
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            // print("IMage ICON FOR TABLE: \(item.icon)")
            
            image = item.icon
            text = item.name
            cellIdentifier = CellIdentifiers.NameCell
            
        } else if tableColumn == tableView.tableColumns[1] {
            
            text = dateFormatter.string(from: item.date)
            cellIdentifier = CellIdentifiers.DateCell
            
        } else if tableColumn == tableView.tableColumns[2] {
            
            text = item.isFolder ? "--" : sizeFormatter.string(fromByteCount: item.size)
          
            cellIdentifier = CellIdentifiers.SizeCell
        
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            
            
            cell.backgroundStyle = NSBackgroundStyle.dark
    
            let layer:CALayer = CALayer()
            layer.backgroundColor = self.appDelegate.appSettings.appViewBackgroundColor.cgColor
            
            
            cell.wantsLayer = true
            cell.layer = layer
            
            
            
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
}


