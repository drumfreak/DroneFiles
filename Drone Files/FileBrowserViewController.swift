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
    @IBOutlet weak var splitViewController: SplitViewController!
    @IBOutlet weak var projectDirectoryLabel: NSTextField!

    
    // Directories!
    var directory: Directory?
    var sourceFolder = "file:///Volumes/DroneStick1/DCIM/100MEDIA/"
    var fileSequenceName = ""
    var fileSequenceNameTag = ""
    var projectDirectory = ""
    var outputDirectory = ""
    var createProjectDirectory = true
    var createProjectSubDirectories = true
    
    var sourceFolderOpened: Any? {
        didSet {
            if let url = sourceFolderOpened as? URL {
                // print("Source Folder Opened: \(url)")
                directory = Directory(folderURL: url)
                self.reloadFileList()
                self.currentDir = url
                self.folderURL = url.absoluteString
                self.folderURLDisplay.stringValue = self.urlStringToDisplayPath(input: self.folderURL)
                UserDefaults.standard.setValue(self.folderURL, forKey: "sourceDirectory")
            }
        }
    }

    
    // URL
    var startingDirectory: URL!
    
    var currentDir: URL!
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    
    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet var saveDirectoryName: String!
    @IBOutlet weak var fileSequenceNameTextField: NSTextField!
    @IBOutlet var folderURL: String!
    @IBOutlet weak var folderURLDisplay: NSTextField!
    @IBOutlet var outputDirectoryLabel: NSTextField!
    @IBOutlet var createProjectDirectoryButton: NSButton!
    @IBOutlet var createProjectSubDirectoriesButton: NSButton!
    
    @IBOutlet var sequenceNameSetButton: NSButton!
    let sizeFormatter = ByteCountFormatter()
    
    @IBOutlet var fileBrowserHomeButton: NSButton!
    
    var projectFolder = "My Project"
    var screenShotFolder = " - Screenshots"
    var videoFolder = " - Videos"
    var jpgFolder = " - JPG"
    var dngFolder = " - RAW"
    var rawFolder = " - RAW"
    var videoClipsFolder = " - Video Clips"
    var previousUrlString = "file://"
    
    // Tableviews - File List
    @IBOutlet var tableView: NSTableView!
    var sortOrder = Directory.FileOrder.Name
    var sortAscending = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "MM-dd-YYYY"
        let now = dateformatter.string(from: NSDate() as Date)
        
        self.fileSequenceName = now + " - " + self.fileSequenceNameTag

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
        
        self.sourceFolder = defaults.value(forKey: "sourceDirectory") as! String
        self.outputDirectory = defaults.value(forKey: "outputDirectory") as! String
        self.fileSequenceNameTag = defaults.value(forKey: "fileSequenceNameTag") as! String
        self.startingDirectory = URL(string: self.sourceFolder)
        self.sourceFolderOpened = self.startingDirectory
        self.fileSequenceName = self.fileSequenceNameTag

        
        self.createProjectSubDirectoriesButton.state = (defaults.value(forKey: "createProjectSubDirectories") as! Int)
        self.createProjectDirectoryButton.state = (defaults.value(forKey: "createProjectDirectory") as! Int)
        
        if(self.createProjectSubDirectoriesButton.state == 0) {
            self.createProjectSubDirectories = false
        }
        
        if(self.createProjectDirectoryButton.state == 0) {
            self.createProjectDirectory = false
        }

        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.statusLabel.stringValue = "0 Items Selected"
        self.tableView.target = self
        self.tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        self.fileSequenceNameTextField.stringValue = self.fileSequenceName
        
        self.saveDirectoryName = self.fileSequenceName
        
        //videoView.
        self.showNotification(messageType: "default", customMessage: "");
        
        self.currentDir = self.startingDirectory
        
        // self.outputDirectory = self.currentDir.absoluteString
        
        self.outputDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.outputDirectory)
        
        setupProjectDirectory()
        
        let descriptorName = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
        let descriptorDate = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: true)
        let descriptorSize = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)
        
        self.tableView.tableColumns[0].sortDescriptorPrototype = descriptorName
        self.tableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
        self.tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
        
        self.sourceFolderOpened = self.startingDirectory
        self.folderURL = self.startingDirectory?.absoluteString
        
        self.folderURLDisplay.stringValue = urlStringToDisplayPath(input:self.folderURL)
        
        reloadFileList()
        
        self.appDelegate.fileBrowserViewController = self
        
        // writeProjectFile(projectPath: self.outputDirectory)
        
        
        
        // Click Gestures
        
        let tapGestureFolder1 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath1))
        
        self.folderURLDisplay.addGestureRecognizer(tapGestureFolder1)
    
        
        let tapGestureFolder2 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath2))
        
        self.outputDirectoryLabel.addGestureRecognizer(tapGestureFolder2)
    
        let tapGestureFolder3 = NSClickGestureRecognizer(target: self, action: #selector(setOpenPath3))
        
        self.projectDirectoryLabel.addGestureRecognizer(tapGestureFolder3)
        
    }
    
    
    
    func setOpenPath1() {
        // self.sourceFolderOpened =  URL(string: self.sourceFolderOpened.absoluteString)
        
    }
    
    
    func setOpenPath2() {
        self.sourceFolderOpened = URL(string: self.outputDirectory)
    }
    
    
    func setOpenPath3() {
        print("RUNNING");
        self.sourceFolderOpened = URL(string: self.projectFolder)
    }

    @IBAction func fileBrowserHomeButtonClicked(_ sender: AnyObject?) {
        // print ("Clicked home button")
        
        let paths = getPathsFromURL(url: self.currentDir)
        
        // print("Paths: \(paths)")
        let tmp = paths["paths"] as! NSArray
        var counter = Int(0)
        
        let previousIndex = paths["parentIndex"] as! Int
        
        // print("previousIndex \(String(describing: previousIndex))")
        self.previousUrlString = "file://"
        
        tmp.forEach { thisPath in
            print(thisPath)
            if(counter <= previousIndex) {
                self.previousUrlString = self.previousUrlString + "/" + (thisPath as! String)
            }
            
            if(counter == previousIndex) {
                // print("SHOULD OPEN " + self.previousUrlString)

                self.sourceFolderOpened = URL(string: self.previousUrlString)
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
                self.sourceFolder = (openPanel.url?.absoluteString)!
                self.startingDirectory = openPanel.url
                self.sourceFolder = (openPanel.url?.absoluteString)!
                
                UserDefaults.standard.setValue(self.sourceFolder, forKey: "sourceDirectory")
                self.folderURLDisplay.stringValue = self.urlStringToDisplayPath(input: (openPanel.url?.absoluteString)!)
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
                self.outputDirectory = (openPanel.url?.absoluteString)!
                self.outputDirectoryLabel.stringValue = self.urlStringToDisplayPath(input: self.outputDirectory)
                UserDefaults.standard.setValue(self.outputDirectory, forKey: "outputDirectory")
                
                self.setupProjectDirectory()
            }
            
        })
    }
    
    @IBAction func createProjectDirectoryCheckbox(_ sender: AnyObject?) {
        self.createProjectDirectory = !self.createProjectDirectory
        if(self.createProjectDirectory) {
            UserDefaults.standard.setValue(1, forKey: "createProjectDirectory")
        } else {
            UserDefaults.standard.setValue(0, forKey: "createProjectDirectory")
        }

        self.setupProjectDirectory()
    }
    
    @IBAction func createProjectSubDirectoriesCheckbox(_ sender: AnyObject?) {
        self.createProjectSubDirectories = !self.createProjectSubDirectories
        if(self.createProjectSubDirectories) {
            UserDefaults.standard.setValue(1, forKey: "createProjectSubDirectories")
        } else {
            UserDefaults.standard.setValue(0, forKey: "createProjectSubDirectories")
        }
        self.setupProjectDirectory()
    }
    
    // Helper Functions
    func setupProjectDirectory() {
        self.saveDirectoryName =  self.fileSequenceName
        self.projectFolder = self.outputDirectory + self.saveDirectoryName
        
        if(self.createProjectDirectory) {
            self.projectFolder = self.outputDirectory + self.saveDirectoryName
        } else {
            self.projectFolder = self.outputDirectory
        }
        
        self.projectDirectory = urlStringToDisplayPath(input: self.projectFolder)
        self.projectDirectoryLabel.stringValue = self.projectDirectory

        if(self.createProjectSubDirectories) {
            self.videoFolder = self.projectFolder + "/" + self.saveDirectoryName + " - Videos"
            self.videoClipsFolder = self.projectFolder + "/" + self.saveDirectoryName + " - Video Clips"
            self.jpgFolder = self.projectFolder + "/" + self.saveDirectoryName + " - JPG"
            self.screenShotFolder = self.projectFolder + "/" + self.saveDirectoryName + " - Frames"
            self.rawFolder = self.projectFolder + "/" + self.saveDirectoryName + " - RAW"
            self.dngFolder = self.projectFolder + "/" + self.saveDirectoryName + " - RAW"
        } else {
            self.videoFolder = self.projectFolder + "/"
            self.videoClipsFolder = self.projectFolder  + "/"
            self.jpgFolder = self.projectFolder  + "/"
            self.screenShotFolder = self.projectFolder  + "/"
            self.rawFolder = self.projectFolder  + "/"
            self.dngFolder = self.projectFolder  + "/"
        }
        
        self.projectFolder = self.projectFolder.replacingOccurrences(of: " ", with: "%20")
        self.videoFolder = self.videoFolder.replacingOccurrences(of: " ", with: "%20")
        self.videoClipsFolder = self.videoClipsFolder.replacingOccurrences(of: " ", with: "%20")
        self.jpgFolder = self.jpgFolder.replacingOccurrences(of: " ", with: "%20")
        self.screenShotFolder = self.screenShotFolder.replacingOccurrences(of: " ", with: "%20")
        self.rawFolder = self.rawFolder.replacingOccurrences(of: " ", with: "%20")
        self.dngFolder = self.dngFolder.replacingOccurrences(of: " ", with: "%20")
        
        self.appDelegate.fileManagerOptionsOrganizeController?.setupProjectPaths()
        
        
//        print("Project Folder: " + self.urlStringToDisplayURLString(input: self.projectFolder))
//        print("Video Folder: " + self.urlStringToDisplayURLString(input:self.videoFolder))
//        print("Video Clips Folder: " + self.urlStringToDisplayURLString(input:self.videoClipsFolder))
//        print("JPG Folder: " + self.urlStringToDisplayURLString(input:self.jpgFolder))
//        print("PNG Folder: " + self.urlStringToDisplayURLString(input:self.screenShotFolder))
//        print("RAW Folder: " + self.urlStringToDisplayURLString(input:self.rawFolder))
//        print("DNG Folder: " + self.urlStringToDisplayURLString(input:self.dngFolder))

    }
    
    // Button and Input Text Actions
    @IBAction func fileSequenceLabelChanged(sender: AnyObject) {
//        self.fileSequenceName = self.fileSequenceNameTextField.stringValue
//        self.newFileNamePath.stringValue = self.fileSequenceName
//        print("New Sequence Name \( self.fileSequenceName)")
//        
//        UserDefaults.standard.setValue(self.fileSequenceName, forKey: "fileSequenceNameTag")
//
//        setupProjectDirectory()
    }
    
    @IBAction func fileSequenceNameSetButtonClicked(sender: AnyObject) {
        
        self.fileSequenceNameTextField.resignFirstResponder()
        
        self.fileSequenceName = self.fileSequenceNameTextField.stringValue
        // self.newFileNamePath.stringValue = self.fileSequenceName
        print("New Sequence Name \( self.fileSequenceName)")
        
        UserDefaults.standard.setValue(self.fileSequenceName, forKey: "fileSequenceNameTag")
        
        setupProjectDirectory()
        
        
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
        self.sourceFolderOpened = URL(string: self.folderURL)
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
            
            if(_extension == "MOV" || _extension == "mov" || _extension == "mp4" || _extension == "MP4" || _extension == "m4v" || _extension == "M4V") {
                
                self.appDelegate.editorTabViewController.selectedTabViewItemIndex = 0
                
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
                
                self.appDelegate.editorTabViewController.selectedTabViewItemIndex = 2
                
                // nowPlayingFile.stringValue = item.name;
                var itemUrl = (item.url as URL).absoluteString
                itemUrl = itemUrl.replacingOccurrences(of: "file://", with: "")
                // print("~~~~~~~~~~~~~~~~~~~~~~~ NOW SHOWING IMAGE: " + itemUrl)
                
                // self.imageEditorViewController.VideoEditView.isHidden = false;
                
                
                // HEY FUCKER YOU MUST SWITCH TABS FIRST OR THIS BREAKS!
                self.appDelegate.editorTabViewController.selectedTabViewItemIndex = 2
                
                self.appDelegate.imageEditorViewController.nowPlayingURL = (item.url as URL)
                self.appDelegate.imageEditorViewController.nowPlayingFile?.stringValue = item.name
                self.appDelegate.imageEditorViewController.nowPlayingURLString = itemUrl
                self.appDelegate.imageEditorViewController.loadImage(_url: item.url as URL)
                
            } else {
                // self.videoPlayerViewController.VideoEditView.isHidden = true;
            }
        }
        
    }
    
    func sendItemsToFileManager (showTab: Bool) {
        let selectedFileURLS: NSMutableArray = []
        for (_, index) in self.tableView.selectedRowIndexes.enumerated() {
            guard index >= 0,
                let item = directoryItems?[index] else {
                    return
            }
            
            // print("SELECTED ITEMS \(item.url)")
            
            selectedFileURLS.add(item.url)
            
        }
    
        if(showTab) {
            self.appDelegate.editorTabViewController.selectedTabViewItemIndex = 3

        }

        self.appDelegate.fileManagerViewController?.fileURLs = selectedFileURLS

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
    
    func writeProjectFile (projectPath: String) {
        
        let documentsDirectoryPath = NSURL(string: projectPath)!
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent(".dronefiles")
        
        print("jsonFilePath \(String(describing: jsonFilePath))")
        
        let fileManager = FileManager.default
        
        var isDirectory: ObjCBool = false
        
        // creating a .json file in the Documents folder
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
        var numbers = [String]()
        for i in 0 ..< 100 {
            numbers.append("Test\(i)")
        }
        
        // creating JSON out of the above array
        var jsonData: NSData!
        do {
            jsonData = try JSONSerialization.data(withJSONObject: numbers, options: JSONSerialization.WritingOptions()) as NSData
            let jsonString = String(data: jsonData as Data, encoding: String.Encoding.utf8)
            print("\(String(describing: jsonString))")
        } catch let error as NSError {
            print("Array to JSON conversion failed: \(error.localizedDescription)")
        }
        
        // Write that JSON to the file created earlier
        // let jsonFilePath = documentsDirectoryPath.appendingPathComponent("test.json")
        do {
            // let file = try FileHandle(forWritingToURL: jsonFilePath!)
            
            let file = try FileHandle.init(forWritingTo: jsonFilePath!)
            file.write(jsonData as Data)

            
            print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
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
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
}


