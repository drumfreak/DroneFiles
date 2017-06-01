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
    
    var doSaveFavorites = false
    
    @IBOutlet var backgroundImage: NSImageView!
    // Directories!
    var directory: Directory?
    
    var sourceFolderOpened: URL! {
        didSet {
            if let url = sourceFolderOpened {
                // print("Source Folder Opened: \(url)")
                directory = Directory(folderURL: url)
            
                self.reloadFileList()
                
                self.appDelegate.appSettings.folderURL = url.absoluteString
                
                self.currentFolderPathControl.url = URL(string: self.appDelegate.appSettings.folderURL)
                
                UserDefaults.standard.setValue(self.appDelegate.appSettings.folderURL, forKey: "sourceDirectory")
                
                self.appDelegate.appSettings.lastFolderOpened = url.absoluteString
                
                // self.startingDirectory = url
                
                self.appDelegate.appSettings.folderURL = url.absoluteString
            }
        }
    }
    
    
    // URL
    
    // var currentDir: URL!
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    
    @IBOutlet weak var newFileNamePath: NSTextField!
    // @IBOutlet weak var fileSequenceNameTextField: NSTextField!
    @IBOutlet weak var folderURLDisplay: NSTextField!
    @IBOutlet var outputDirectoryLabel: NSTextField!
    @IBOutlet var createProjectDirectoryButton: NSButton!
    @IBOutlet var createProjectSubDirectoriesButton: NSButton!
    
    @IBOutlet var sequenceNameSetButton: NSButton!
    let sizeFormatter = ByteCountFormatter()
    
    @IBOutlet var fileBrowserHomeButton: NSButton!
    @IBOutlet var favoriteButton: NSButton!
    
    
    var selectedFileURLS: NSMutableArray = []
    var addToFavoriteUrls = [URL]()
    
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
    
    
    var blockFileLoad = false
    
    // var pathControlDelegate: NSPathControlDelegate!
    
    // Tableviews - File List
    @IBOutlet var tableView: NSTableView!
    var sortOrder = Directory.FileOrder.Name
    var sortAscending = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd-YYYY"
        let now = dateformatter.string(from: NSDate() as Date)
        
        self.appDelegate.appSettings.fileSequenceName = now + " - " + self.appDelegate.appSettings.fileSequenceNameTag
        
        let defaults = UserDefaults.standard

        
        
        if(defaults.value(forKey: "lastFolderOpened") != nil) {
            self.sourceFolderOpened =  URL(string: defaults.value(forKey: "lastFolderOpened") as! String)
        }
        
        
        self.appDelegate.appSettings.sourceFolder = defaults.value(forKey: "sourceDirectory") as! String
        self.appDelegate.appSettings.outputDirectory = defaults.value(forKey: "outputDirectory") as! String
        
        
        self.appDelegate.appSettings.fileSequenceNameTag = defaults.value(forKey: "fileSequenceNameTag") as! String
        
        // self.appDelegate.appSettings.sourceFolder)
        
        self.appDelegate.appSettings.fileSequenceName = self.appDelegate.appSettings.fileSequenceNameTag
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        DispatchQueue.main.async {
            self.statusLabel.stringValue = "0 Items Selected"
            // self.fileSequenceNameTextField.stringValue = self.appDelegate.appSettings.fileSequenceName
            self.appDelegate.appSettings.saveDirectoryName = self.appDelegate.appSettings.fileSequenceName
        }
        
        self.tableView.target = self
        self.tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        self.currentFolderPathControl.delegate = self
        
        setupProjectDirectory()
        
        
        let descriptorName = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
        let descriptorDate = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: true)
        let descriptorSize = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)
        
         let descriptorFavorite = NSSortDescriptor(key: Directory.FileOrder.Favorite.rawValue, ascending: true)
        
        self.tableView.tableColumns[0].sortDescriptorPrototype = descriptorName
        self.tableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
        self.tableView.tableColumns[2].sortDescriptorPrototype = descriptorFavorite
        
        self.tableView.tableColumns[3].sortDescriptorPrototype = descriptorSize
        
        
        // self.sourceFolderOpened = self.startingDirectory
        
        reloadFileList()
        
        self.appDelegate.fileBrowserViewController = self
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        // self.fileSequenceNameTextField.stringValue = self.appSettings.fileSequenceName
        // self.openLastFile();
        self.setupPathControl(control: self.currentFolderPathControl)
        
    }
    
    @IBAction func openCurrentPathControlMenu(_ sender: AnyObject?) {
        self.currentFolderPathControl.menu?.popUp(positioning: self.currentFolderPathControl.menu?.item(at:0), at: NSPoint(dictionaryRepresentation: 0 as! CFDictionary)!, in: self.view)
        
    }
    
    @IBAction func selectHeart(button: FavoriteButtonTable) {
//        print("Fuck yeah \(button.itemIndex)")
//        
//        print(button.buttonUrl)
        self.doSaveFavorites = true
        
        if(self.tableView.selectedRow == button.itemIndex) {
            self.sendItemsToFileManager(showTab: false)
        } else {
            self.selectRowAtIndex(index: button.itemIndex, false)
        }
    }
    
    
    func selectNextItem() {
        if(self.tableView.selectedRow > -1) {
            
            let i = self.tableView.selectedRow
            
            if(i < self.tableView.numberOfRows) {
                let indexSet =  NSIndexSet(index: i + 1) as IndexSet
                
                DispatchQueue.main.async {
                    self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
                }
            }
            
        } else {
            
            let indexSet =  NSIndexSet(index: 0) as IndexSet
            
            DispatchQueue.main.async {
                self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
            }
        }
        
    }
    
    
    func selectPreviousItem() {
        if(self.tableView.selectedRow < self.tableView.numberOfRows) {
            
            let i = self.tableView.selectedRow
            
            if(i > -1) {
                let indexSet =  NSIndexSet(index: i - 1) as IndexSet
                if((i - 1) > -1) {
                    DispatchQueue.main.async {
                        self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
                    }
                }
            }
        }
    }
    
    
    func selectRowAtIndex(index: Int, _ extend: Bool) {
        if(index < self.tableView.numberOfRows) {
            
            let i = index
            
            if(i > -1) {
                let indexSet =  NSIndexSet(index: i) as IndexSet
                
               // DispatchQueue.main.async {
                    self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
               // }
            }
        }
    }
    
    func setupPathControl(control: NSPathControl) {
        var i = 0
        
        DispatchQueue.main.async {
            control.backgroundColor = NSColor.clear
            control.pathItems.forEach {m in
                var colorRanges: [NSRange] = []
                m.attributedTitle.enumerateAttribute(NSForegroundColorAttributeName, in: NSRange(0..<m.attributedTitle.length), options: .longestEffectiveRangeNotRequired) {
                    value, range, stop in
                    
                    
                    //Confirm the attribute value is actually a color
                    if (value as? NSColor) != nil {
                        // print(color)
                        colorRanges.append(range)
                    }
                }
                
                
                //Replace their colors.
                let mutableAttributedText = m.attributedTitle.mutableCopy() as! NSMutableAttributedString
                
                for colorRange in colorRanges {
                    mutableAttributedText.addAttribute(NSForegroundColorAttributeName, value: NSColor.darkGray, range: colorRange)
                }
                m.attributedTitle = mutableAttributedText
                control.pathItems[i] = m
                
                i += 1
            }
        }
    }
    
    func openLastFile() {
        
        // let defaults = UserDefaults.standard
        
        if((self.appSettings.lastFileOpened) != nil) {
            //print("OPENING THE FUCKING File")
            
            let lastFile =  URL(string: self.appSettings.lastFileOpened!)
            
            //            if(isMov(file:lastFile!)) {
            //
            //
            //                // print("LOADING MOV!!!!!!!")
            //
            //                self.appDelegate.editorTabViewController?.selectedTabViewItemIndex = 0
            //
            //                // nowPlayingFile.stringValue = item.name;
            //                var itemUrl = lastFile?.absoluteString
            //                itemUrl = itemUrl?.replacingOccurrences(of: "file://", with: "")
            //
            //
            //                //self.appDelegate.videoControlsController?.nowPlayingFile.stringValue = lastFile.lastPathComponent
            //                self.appDelegate.videoPlayerViewController?.nowPlayingURL = lastFile
            //
            //                self.appDelegate.videoControlsController?.currentVideoURL = lastFile
            //
            //                self.appDelegate.videoControlsController?.nowPlayingURLString = lastFile?.absoluteString
            //
            //                // self.appDelegate.videoPlayerViewController?.playVideo(_url: lastFile, frame:kCMTimeZero, startPlaying: true);
            //
            //                // self.appDelegate.appSettings.lastFileOpened = item.url.absoluteString
            //
            //
            //            }
            //
            //            if(isImage(file:lastFile!)) {
            //
            //                //  print("LOADING IMAGE!!!!!!!")
            //
            //                // HEY FUCKER YOU MUST SWITCH TABS FIRST OR THIS BREAKS!
            //                self.appDelegate.editorTabViewController?.selectedTabViewItemIndex = 1
            //                self.appDelegate.imageEditorViewController?.loadImage(_url:lastFile!)
            //
            //                // self.appDelegate.appSettings.lastFileOpened = lastFile.absoluteString
            //            }
            
            
            self.reloadFilesWithSelected(fileName: (lastFile?.absoluteString)!)
            
            
            // print(lastFile)
            
            
        }
    }
    
    func isMov(file: URL) -> Bool {
        let movs = ["MOV", "mov", "mp4", "MP4", "m4v", "M4V", "AVI", "avi"]
        if((movs.index(of: file.pathExtension)) != nil) {
            return true
        } else {
            return false
        }
    }
    
    func isImage(file: URL) -> Bool {
        let images = ["JPG", "jpg", "JPEG", "jpeg", "TIFF", "tiff", "DNG", "DNG", "png", "PNG", "BMP", "bmp"]
        
        if((images.index(of: file.pathExtension)) != nil) {
            return true
        } else {
            return false
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
                UserDefaults.standard.setValue(self.appDelegate.appSettings.sourceFolder, forKey: "sourceDirectory")
                //self.folderURLDisplay.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
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
                    self.appDelegate.readProjectFile(projectFile: (openPanel.url?.absoluteString)!)
                    
                    self.setupProjectDirectory()
                    self.sourceFolderOpened = URL(string: self.appSettings.projectDirectory)
                    
                    
                    //                    self.appDelegate.documentController.openDocument(withContentsOf: openPanel.url!, display: true, completionHandler: { (document: NSDocument?, wasOpen: Bool, err: Error?) in
                    //                        print("Fuck yeah \(String(describing: document))")
                    //                        print("Error: \(String(describing: err))")
                    //                    })
                    
                }
            }
            
        })
    }
    
    
    // Add to Favorites
    
    
    @IBAction func addFavorite(_ sender: AnyObject?) {
        // print("Fuck yeah")
        
        var lastUrl: URL!
        self.addToFavoriteUrls.forEach { furl in
            let f = furl
            // print(f)
            
            if(self.appDelegate.appSettings.favoriteUrls.contains(f as URL)) {
                // print("Removing URL to from favorites: \(f)")
                let index = self.appDelegate.appSettings.favoriteUrls.index(of: f as URL)
                self.appDelegate.appSettings.favoriteUrls.remove(at: index!)
                
                DispatchQueue.main.async {
                    
                    self.favoriteButton.image = NSImage(named: "heart-inactive.png")!
                }
            } else {
                DispatchQueue.main.async {
                    
                    self.favoriteButton.image = NSImage(named: "heart-active.png")!
                }
                // print("Adding URL to favorites: \(f)")
                self.appDelegate.appSettings.favoriteUrls.append(f)
            }
            
            lastUrl = f as URL
        }
        
        self.appDelegate.saveProject()
        self.tableView.reloadData()
        
        var i = 0
        
        self.directoryItems?.forEach({ directoryItem in
            
            let turl = directoryItem.url
            
            if(turl.absoluteString == lastUrl?.absoluteString) {
                let indexSet =  NSIndexSet(index: i) as IndexSet
                
                DispatchQueue.main.async {
                    self.blockFileLoad = true
                    self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
                    self.blockFileLoad = false

                }
            }
            i += Int(1)
            
        })

        
        
        // self.addToFavoriteUrls.removeAll(keepingCapacity: false)
        
        // print(self.appDelegate.appSettings.favoriteUrls)
        
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
        // self.projectDirectoryLabel.stringValue = self.appDelegate.appSettings.projectDirectory
        
        if(self.appDelegate.appSettings.createProjectSubDirectories) {
            
            self.appDelegate.appSettings.videoFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - Videos"
            
            self.appDelegate.appSettings.videoClipsFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - Video Clips"
            
             self.appDelegate.appSettings.timeLapseFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - TimeLapses"
            
            self.appDelegate.appSettings.jpgFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - JPG"
            
            self.appDelegate.appSettings.screenShotFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - Frames"
            
            self.appDelegate.appSettings.rawFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - RAW"
            
            self.appDelegate.appSettings.dngFolder = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - RAW"
            
            self.appDelegate.appSettings.thumbnailDirectory = self.appDelegate.appSettings.projectFolder + "/" + self.appDelegate.appSettings.saveDirectoryName + " - Thumbnails"
            
        } else {
            
            self.appDelegate.appSettings.videoFolder = self.appDelegate.appSettings.projectFolder + "/"
            
            self.appDelegate.appSettings.videoClipsFolder = self.appDelegate.appSettings.projectFolder  + "/"
            
            self.appDelegate.appSettings.timeLapseFolder = self.appDelegate.appSettings.projectFolder  + "/"
            
            self.appDelegate.appSettings.jpgFolder = self.appDelegate.appSettings.projectFolder  + "/"
            
            self.appDelegate.appSettings.screenShotFolder = self.appDelegate.appSettings.projectFolder  + "/"
            
            self.appDelegate.appSettings.rawFolder = self.appDelegate.appSettings.projectFolder  + "/"
            
            self.appDelegate.appSettings.dngFolder = self.appDelegate.appSettings.projectFolder  + "/"
            
            self.appDelegate.appSettings.thumbnailDirectory = self.appDelegate.appSettings.projectFolder  + "/thumbnails"
        }
        
        self.appDelegate.appSettings.projectFolder = self.appDelegate.appSettings.projectFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.appSettings.videoFolder = self.appDelegate.appSettings.videoFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.appSettings.videoClipsFolder = self.appDelegate.appSettings.videoClipsFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.appSettings.timeLapseFolder = self.appDelegate.appSettings.timeLapseFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.appSettings.jpgFolder = self.appDelegate.appSettings.jpgFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.appSettings.screenShotFolder = self.appDelegate.appSettings.screenShotFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.appSettings.rawFolder = self.appDelegate.appSettings.rawFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.appSettings.dngFolder = self.appDelegate.appSettings.dngFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.appSettings.thumbnailDirectory = self.appDelegate.appSettings.thumbnailDirectory.replacingOccurrences(of: " ", with: "%20")
        

    self.appDelegate.fileManagerOptionsOrganizeController?.setupProjectPaths()
        
        //self.sourceFolderOpened = URL(string: self.appSettings.projectDirectory)!
        
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
    
    
    @IBAction func outputPathControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = URL(string: self.appSettings.outputDirectory)
        
        self.setupPathControl(control: self.currentFolderPathControl)
    }
    
    
    @IBAction func projectControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = URL(string: self.appSettings.projectFolder)
        self.setupPathControl(control: self.currentFolderPathControl)
    }
    
    @IBAction func videosPathControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = URL(string: self.appSettings.videoFolder)
        self.setupPathControl(control: self.currentFolderPathControl)
    }
    
    @IBAction func clipsControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = URL(string: self.appSettings.videoClipsFolder)
        self.setupPathControl(control: self.currentFolderPathControl)
    }
    
    
    @IBAction func timeLapseControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = URL(string: self.appSettings.timeLapseFolder)
        self.setupPathControl(control: self.currentFolderPathControl)
    }
    
    
    @IBAction func framesControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = URL(string: self.appSettings.screenShotFolder)
        self.setupPathControl(control: self.currentFolderPathControl)
        
    }
    
    
    @IBAction func rawControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = URL(string: self.appSettings.rawFolder)
        self.setupPathControl(control: self.currentFolderPathControl)
    }
    
    
    @IBAction func jpgControlSingleClick(sender: AnyObject) {
        self.sourceFolderOpened = URL(string: self.appSettings.jpgFolder)
        self.setupPathControl(control: self.currentFolderPathControl)
    }
    
    
    
    @IBAction func favoritesControlSingleClick(sender: AnyObject) {
        
    }
    
    
    
    
    func reloadFilesWithSelected(fileName: String) {
        
        
        // self.sourceFolderOpened = URL(string: self.appDelegate.appSettings.folderURL)
        
        // DispatchQueue.main.async {
        self.directory = Directory(folderURL: self.sourceFolderOpened)
        self.reloadFileList()
        
        let url = URL(string: fileName)
        var i = 0
        
        self.directoryItems?.forEach({ directoryItem in
            
            let turl = directoryItem.url
            
            if(turl.absoluteString == url?.absoluteString) {
                let indexSet =  NSIndexSet(index: i) as IndexSet
                
                DispatchQueue.main.async {
                    self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
                }
            }
            i += Int(1)
            
        })
        // }
        
    }
    
    
    
    func reloadFileList() {
        //DispatchQueue.main.async {
        self.directoryItems = self.directory?.contentsOrderedBy(self.sortOrder, ascending: self.sortAscending)
        self.tableView.reloadData()
        // }
    }
    
    
    func loadItemFromTable() {
        
        if(self.blockFileLoad) {
            return
        }
        // print("SELECTED ROW \(self.tableView.selectedRow)")
        
        // 1
        guard self.tableView.selectedRow >= 0,
            let item = directoryItems?[self.tableView.selectedRow] else {
                return
        }
        
        if(self.appSettings.favoriteUrls.contains(item.url as URL)) {
           // DispatchQueue.main.async {
                self.favoriteButton.image = NSImage(named: "heart-active.png")!
           // }
        } else {
           // DispatchQueue.main.async {
                self.favoriteButton.image = NSImage(named: "heart-inactive.png")!
           // }
        }
        
        if item.isFolder {
            // 2
            // print("CLICKED FOLDER");
            // self.currentDir = item.url as URL
            // self.representedObject = item.url as Any
        } else {
            
            // print("SELECTED ITEM IS \(item)");
            // 3
            
            let url = NSURL(fileURLWithPath: item.url.absoluteString)
            
            let _extension = url.pathExtension
            
            if(_extension == "dronefiles") {
                self.appDelegate.readProjectFile(projectFile: item.url.absoluteString)
            }
            
            if(isMov(file:item.url)) {
                
                if(!self.appDelegate.appSettings.videoSplitViewIsOpen) {
                    self.appDelegate.rightPanelSplitViewController?.showVideoSplitView()
                }
                
                // nowPlayingFile.stringValue = item.name;
                var itemUrl = url.absoluteString
                itemUrl = itemUrl?.replacingOccurrences(of: "file://", with: "")
                // print("~~~~~~~~~~~~~~~~~~~~~~~ NOW PLAYING: " + itemUrl)
                
                DispatchQueue.main.async {
                    
                    self.appDelegate.videoPlayerViewController?.VideoEditView.isHidden = false
                    self.appDelegate.videoControlsController.nowPlayingFile?.stringValue = item.name
                    
                }
                
                self.appDelegate.videoControlsController.currentVideoURL = item.url as URL
                
                self.appDelegate.videoPlayerViewController?.nowPlayingURL = (item.url as URL)
                
                self.appDelegate.videoControlsController.nowPlayingURLString = itemUrl
                
                self.appDelegate.appSettings.lastFileOpened = item.url.absoluteString
                
                self.appDelegate.secondaryDisplayMediaViewController?.loadVideo(videoUrl: item.url as URL)
                
                self.appDelegate.saveProject()
                
            } else {
                // self.editorTabViewController.videoPlayerViewController.VideoEditView.isHidden = true;
            }
            
            if(isImage(file: item.url)) {
                
                // HEY FUCKER YOU MUST SWITCH TABS FIRST OR THIS BREAKS!
                
                if(!self.appDelegate.appSettings.blockScreenShotTabSwitch) {
                    // DispatchQueue.main.async {
                    
                    if(!self.appDelegate.appSettings.imageEditorSplitViewIsOpen) {
                        self.appDelegate.rightPanelSplitViewController?.showImageEditorSplitView()
                    }
                    
                    
                }
                
                self.appDelegate.imageEditorViewController?.loadImage(_url: item.url as URL)
                
                self.appDelegate.appSettings.lastFileOpened = item.url.absoluteString
                
                self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: item.url as URL)
                
                self.appDelegate.saveProject()
                
                //
                
            } else {
                // self.videoPlayerViewController.VideoEditView.isHidden = true;
            }
        }
        
    }
    
    func sendItemsToFileManager (showTab: Bool) {
        self.selectedFileURLS = []
        self.addToFavoriteUrls.removeAll(keepingCapacity: false)
        
        
        for (_, index) in self.tableView.selectedRowIndexes.enumerated() {
            guard index >= 0,
                let item = directoryItems?[index] else {
                    return
            }
            
            // print("SELECTED ITEMS \(item.url)")
            
            self.selectedFileURLS.add(item.url)
            self.addToFavoriteUrls.append(item.url)
            
        }
        
        if(self.doSaveFavorites) {
            self.addFavorite(self)
            self.doSaveFavorites = false
        }
        
        if(showTab) {
            if(!self.appDelegate.appSettings.fileManagerSplitViewIsOpen) {
                self.appDelegate.rightPanelSplitViewController?.showFileManagerSplitView()
            }
        }
        
        self.appDelegate.fileManagerViewController?.fileURLs = self.selectedFileURLS
    }
    
    @IBAction func openSlideShow(_ sender: AnyObject?) {
        self.appDelegate.slideShowWindowController?.showWindow(self)
        //print("What the fuck man...")
    }
    
    
//    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
//        if segue.identifier == "slideShow" {
//            
//            // print("Doing the segue....")
//            
//           // self.appDelegate.slideShowWindowController = segue.destinationController as? SlideShowWindowController
//            
//            //self.appDelegate.slideShowController?.loadImages(items: self.selectedFileURLS)
//            
//        }
//    }
    
    
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
        DispatchQueue.main.async {
            self.statusLabel.stringValue = text
        }
        
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
            self.sourceFolderOpened = item.url
            // self.currentDir = item.url as URL
        }
        else {
            // 3
            // NSWorkspace.shared().open(item.url as URL)
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
        static let FavoriteCell = "FavoriteCellID"
        static let KindCell = "KindCellID"
    }
    
    
    internal func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
        // print(tableColumn)
        
        
    }
    
    // private func tableView(_ tableView: NSTableView, )
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        //DispatchQueue.main.async {
        tableColumn!.headerCell = ThemeTableHeaderCell(textCell: tableColumn!.title)
        //}
        // tableColumn!.headerCell.backgroundColor = self.appSettings.tableRowSelectedBackGroundColor
        
        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""
        var buttonImage = NSImage.init(named: "heart-table-inactive.png")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        
        // 1
        guard let item = directoryItems?[row] else {
            return nil
        }
        
        let rowView = self.tableView.rowView(atRow: row, makeIfNecessary: false)
        
        if(row % 2 == 0) {
            //DispatchQueue.main.async {
            rowView?.backgroundColor = self.appDelegate.appSettings.tableRowBackGroundColor
            //}
            // cell.backgroundStyle = NSBackgroundStyle.light
        } else {
            // cell.backgroundStyle = NSBackgroundStyle.dark
            //DispatchQueue.main.async {
            rowView?.backgroundColor = self.appDelegate.appSettings.tableViewAlternatingRowColor
            //}
        }
        
        
        // 2
        if tableColumn == tableView.tableColumns[0] {
            image = item.icon
            text = item.name
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[1] {
            text = dateFormatter.string(from: item.date)
            cellIdentifier = CellIdentifiers.DateCell
        } else if tableColumn == tableView.tableColumns[2] {
            //image = item.isFavorite
            
            var isFavorite = false
            if(self.appSettings.favoriteUrls.contains(item.url)) {
                    isFavorite = true
                }  else {
                    isFavorite = false
                }
            if(isFavorite) {
                buttonImage = NSImage.init(named: "heart-table-active.png")
            } else {
                buttonImage = NSImage.init(named: "heart-table-inactive.png")
            }

            cellIdentifier = CellIdentifiers.FavoriteCell
        } else if tableColumn == tableView.tableColumns[3] {
            text = item.isFolder ? "--" : sizeFormatter.string(fromByteCount: item.size)
            cellIdentifier = CellIdentifiers.SizeCell
        }
        
        // 3
        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? FileBrowserTableCellView {
            //DispatchQueue.main.async {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            cell.buttonView?.image = buttonImage
            cell.buttonView?.itemIndex = row
            cell.buttonView?.buttonUrl = item.url
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
        
        // print(notification)
        
        
        var i = Int(0)
        //DispatchQueue.main.async {
            
            while(i < self.tableView.numberOfRows) {
                if(i < 0) {
                    return
                }
                let rowView = self.tableView.rowView(atRow: i, makeIfNecessary: false)
                
                // layer.backgroundColor = self.appDelegate.appSettings.appViewBackgroundColor.cgColor
                
                
                let f = self.tableView.selectedRowIndexes.index(of: i)
                if((f) != nil) {
                    //print("INDEX OF SELECTED ROW: \(i)")
                    rowView?.backgroundColor = self.appDelegate.appSettings.tableRowSelectedBackGroundColor
                    
                    
                } else {
                    //print("Unselected Row... (i)")
                    
                    // Back to alternating colors...
                    
                    if(i % 2 == 0) {
                        rowView?.backgroundColor = self.appDelegate.appSettings.tableRowBackGroundColor
                    } else {
                        rowView?.backgroundColor = self.appDelegate.appSettings.tableViewAlternatingRowColor
                    }
                    
                }
                
                i += 1
                
            }
        
        
            let rowView = self.tableView.rowView(atRow: self.tableView.selectedRow, makeIfNecessary: false)
            
            // layer.backgroundColor = self.appDelegate.appSettings.appViewBackgroundColor.cgColor
            
            // Current row selected color
            rowView?.backgroundColor = self.appDelegate.appSettings.tableRowActiveBackGroundColor
       // }
        
    }
    
    
    // public func tableView
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return ThemeTableRowView()
    }
}

extension FileBrowserViewController: NSPathControlDelegate {
    
    
    public func pathControl(_ pathControl: NSPathControl, shouldDrag pathItem: NSPathControlItem, with pasteboard: NSPasteboard) -> Bool {
        
        return false
        
    }
    //   - (void)insertItemWithTitle:(NSString *)title atIndex:(NSInteger)index;
    
    //  public func
    
    public func pathControl(_ pathControl: NSPathControl, shouldDrag pathComponentCell: NSPathComponentCell, with pasteboard: NSPasteboard) -> Bool {
        
        return false
        
    }
    
    // func
    public func pathControl(_ pathControl: NSPathControl, willPopUp menu: NSMenu) {
        
        // print("FPPasdfasdfasdfasdfasdfasdfasdfasasfd")
        
    }
}


public class FileBrowserTableCellView: NSTableCellView {
    // @IBOutlet var buttonView: NSButton?
    @IBOutlet open var buttonView: FavoriteButtonTable?
    var cellItemUrl: URL!
    
    //override to change background color on highlight
    override public var backgroundStyle:NSBackgroundStyle{
        //check value when the style was setted
        didSet{
            
            self.wantsLayer = true
            
            // DO NOT CHANGE THE FUCKING COLOR!! DO IT TO THE ROW
            
            self.textField?.textColor = self.appSettings.textLabelColor
            
        }
    }
}

public class FavoriteButtonTable: NSButton {
    // @IBOutlet var buttonView: NSButton?
    var buttonUrl: URL!
    var itemIndex: Int = 0
}



