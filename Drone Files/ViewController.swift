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


class ViewController: NSViewController {
    
    @IBOutlet var topView: NSView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var screenshotViewController: ScreenshotViewController!
    // @IBOutlet weak var editorViewController: EditorViewController!
    @IBOutlet weak var editorTabViewController: EditorTabViewController!
    @IBOutlet weak var imageEditorViewController: ImageEditorViewController!

    // View controllers
    
    @IBOutlet var editingContainerView: NSView!
    @IBOutlet var screenShotView: NSView!
    
    // Directories!
    var directory: Directory?
    var startingDirectory = URL(string: "file:///Volumes/NO%20NAME/DCIM/100MEDIA")
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    
    @IBOutlet weak var dateField: NSTextField!
    @IBOutlet weak var flightName: NSTextField!
    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet var saveDirectoryName: String!
    @IBOutlet var flightNameVar: String!
    @IBOutlet var dateNameVar: String!
    @IBOutlet var folderURL: String!
    @IBOutlet weak var folderURLDisplay: NSTextField!
    let sizeFormatter = ByteCountFormatter()
    
    
    var sourceFolder = "file:///Volumes/NO%20NAME/DCIM/100MEDIA"
    var projectFolder = "My Project"
    var screenShotFolder = " - Screenshots"
    var videoFolder = " - Videos"
    var jpgFolder = " - JPG"
    var dngFolder = " - RAW"
    var rawFolder = " - RAW"
    var videoClipsFolder = " - Video Clips"
    
    // Tableviews - File List
    @IBOutlet var tableView: NSTableView!
    var sortOrder = Directory.FileOrder.Name
    var sortAscending = true
    
    // Other Views
    @IBOutlet var VideoEditView: NSView!
    @IBOutlet var PhotoEditView: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController Loaded")
        
        tableView.delegate = self
        tableView.dataSource = self
        statusLabel.stringValue = ""
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        // tableView.
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM-dd-YYYY"
        
        let now = dateformatter.string(from: NSDate() as Date)
        
        dateField.stringValue = now
        
        self.flightName.stringValue = "Drone Flight"
        self.flightNameVar = flightName.stringValue
        self.dateNameVar = dateField.stringValue
        
        self.saveDirectoryName = self.dateNameVar + " - " + self.flightNameVar
        
        // Find the view
        // let videoView = self.editingContainerView.subviews[0]! as videoPlayerViewController
        
        
        //videoView.
        self.showNotification(messageType: "default", customMessage: "");
        
        setupProjectDirectory()
        
        let descriptorName = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
        let descriptorDate = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: true)
        let descriptorSize = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)
        
        tableView.tableColumns[0].sortDescriptorPrototype = descriptorName
        tableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
        tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
        
        self.representedObject = self.startingDirectory
        self.folderURL = self.startingDirectory?.absoluteString
        let tmp = self.folderURL.replacingOccurrences(of: "file://", with: "")
        self.folderURLDisplay.stringValue = tmp.replacingOccurrences(of: "%20", with: " ")
        
        reloadFileList()
        
    }
    

    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "editorTabViewSegue" {
            self.editorTabViewController = segue.destinationController as! EditorTabViewController
           
            self.videoPlayerViewController = self.editorTabViewController.childViewControllers[0] as! VideoPlayerViewController
            
            self.videoPlayerViewController.folderURL = self.folderURL
            self.videoPlayerViewController.saveDirectoryName = self.saveDirectoryName
            self.videoPlayerViewController.flightNameVar = self.flightNameVar
            self.videoPlayerViewController.dateNameVar = self.dateNameVar
            self.videoPlayerViewController.flightName = self.flightName
            self.videoPlayerViewController.dateField = self.dateField
            
            print ("Editor Tab View Controller Loaded");
            
            
            self.screenshotViewController = self.editorTabViewController.childViewControllers[1] as! ScreenshotViewController
            
            self.imageEditorViewController = self.editorTabViewController.childViewControllers[2] as! ImageEditorViewController
            
            self.imageEditorViewController.folderURL = self.folderURL
            self.imageEditorViewController.saveDirectoryName = self.saveDirectoryName
            self.imageEditorViewController.flightNameVar = self.flightNameVar
            self.imageEditorViewController.dateNameVar = self.dateNameVar
            self.imageEditorViewController.flightName = self.flightName
            self.imageEditorViewController.dateField = self.dateField
            
            
            self.screenshotViewController.mainViewController = self
            self.videoPlayerViewController.mainViewController = self
            self.videoPlayerViewController.editorTabViewContrller = self.editorTabViewController
//            self.screenshotViewController.editorTabViewController = self.editorTabViewController
            
            self.videoPlayerViewController.screenshotViewController = self.screenshotViewController
        }
        
        
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
                //print(openPanel.urls)
            }
            self.representedObject = openPanel.url
            
            self.sourceFolder = (openPanel.url?.absoluteString)!
            
            let tmp = openPanel.url?.absoluteString.replacingOccurrences(of: "file://", with: "")
            self.folderURLDisplay.stringValue = (tmp!.replacingOccurrences(of: "%20", with: " "))
            
        })
    }
    
    // Helper Functions
    func setupProjectDirectory() {
        self.flightNameVar = self.flightName.stringValue
        self.dateNameVar = self.dateField.stringValue
        self.newFileNamePath.stringValue = dateField.stringValue + " - " + flightName.stringValue
        self.saveDirectoryName =  self.newFileNamePath.stringValue
        
        self.projectFolder = (self.startingDirectory?.absoluteString)! + "/" + self.saveDirectoryName
        self.videoFolder = self.projectFolder + "/" + self.saveDirectoryName + " - Videos"
        self.videoClipsFolder = self.projectFolder + "/" + self.saveDirectoryName + " - Video Clips"
        self.jpgFolder = self.projectFolder + "/" + self.saveDirectoryName + " - JPG"
        self.screenShotFolder = self.projectFolder + "/" + self.saveDirectoryName + " - Frames"
        self.rawFolder = self.projectFolder + "/" + self.saveDirectoryName + " - RAW"
        self.dngFolder = self.projectFolder + "/" + self.saveDirectoryName + " - RAW"
        
        self.projectFolder = self.projectFolder.replacingOccurrences(of: " ", with: "%20")
        self.videoFolder = self.videoFolder.replacingOccurrences(of: " ", with: "%20")
        self.videoClipsFolder = self.videoClipsFolder.replacingOccurrences(of: " ", with: "%20")
        self.jpgFolder = self.jpgFolder.replacingOccurrences(of: " ", with: "%20")
        self.screenShotFolder = self.screenShotFolder.replacingOccurrences(of: " ", with: "%20")
        self.rawFolder = self.rawFolder.replacingOccurrences(of: " ", with: "%20")
        self.dngFolder = self.dngFolder.replacingOccurrences(of: " ", with: "%20")
        
        
        print("Project Folder:" + self.projectFolder)
        print("Video Folder:" + self.videoFolder)
        print("Video Clips Folder:" + self.videoClipsFolder)
        print("JPG Folder:" + self.jpgFolder)
        print("PNG Folder:" + self.screenShotFolder)
        print("RAW Folder:" + self.rawFolder)
        print("DNG Folder:" + self.dngFolder)


        
    }
    
    // Button and Input Text Actions
    @IBAction func flightNameChanged(sender: AnyObject) {
        setupProjectDirectory()
    }
    
    @IBAction func dateNameChanged(swnder: AnyObject) {
        setupProjectDirectory()
    }
    
    
    // Overrides
    
    //    override func keyDown(with event: NSEvent) {
    //        if (event.keyCode == 53){
    //            print("ESC KEY hit");
    //            //do whatever when the s key is pressed
    //        }
    //    }
    
    override var representedObject: Any? {
        didSet {
            if let url = representedObject as? URL {
                // print("Represented object: \(url)")
                directory = Directory(folderURL: url)
                reloadFileList()
                self.folderURL = url.absoluteString
                let tmp = url.absoluteString.replacingOccurrences(of: "file://", with: "")
                // print("TMP" + tmp)
                self.folderURLDisplay.stringValue = tmp.replacingOccurrences(of: "%20", with: " ")
            }
        }
    }
    
    
    func showNotification(messageType: String, customMessage: String) -> Void {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if(messageType == "VideoTrimComplete") {
                // print("Message Type VIDEO TRIM COMPLETE: " + messageType);
                let notification = NSUserNotification()
                notification.title = "Video Trimming Complete"
                notification.informativeText = "Your clip has been saved. " + customMessage.replacingOccurrences(of: "%20", with: " ")
                
                notification.soundName = NSUserNotificationDefaultSoundName
                // NSUserNotificationCenter.default.deliver(notification)
                NSUserNotificationCenter.default.deliver(notification);
            }
            
            if(messageType == "default") {
                // print("Message Type Welcome: " + messageType);
                let notification = NSUserNotification()
                notification.title = "Welcome to DroneFiles!"
                notification.informativeText = "Your life will never be the same"
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notification)
            }
        }
    }
    
    
    func reloadFileList() {
        directoryItems = directory?.contentsOrderedBy(sortOrder, ascending: sortAscending)
        tableView.reloadData()
    }
    
    
    func loadItemFromTable() {
    
        print("SELECTED ROW \(self.tableView.selectedRow)")
        
        
        // 1
        guard tableView.selectedRow >= 0,
            let item = directoryItems?[tableView.selectedRow] else {
                return
        }
        
        if item.isFolder {
            // 2
            self.representedObject = item.url as Any
        }
        else {
            
            // print("SELECTED ITEM IS \(item)");
            // 3
            
            let url = NSURL(fileURLWithPath: item.url.absoluteString)
            
            let _extension = url.pathExtension
            
            if(_extension == "MOV" || _extension == "mov" || _extension == "mp4" || _extension == "MP4" || _extension == "m4v" || _extension == "M4V") {
                
                self.editorTabViewController.selectedTabViewItemIndex = 0
                
                // nowPlayingFile.stringValue = item.name;
                var itemUrl = (item.url as URL).absoluteString
                itemUrl = itemUrl.replacingOccurrences(of: "file://", with: "")
                print("~~~~~~~~~~~~~~~~~~~~~~~ NOW PLAYING: " + itemUrl)
                
                self.videoPlayerViewController.VideoEditView.isHidden = false;
                self.videoPlayerViewController.nowPlayingFile.stringValue = item.name
                self.videoPlayerViewController.nowPlayingURL = (item.url as URL)
                
                self.videoPlayerViewController.nowPlayingURLString = itemUrl
                
                self.videoPlayerViewController.playVideo(_url: item.url as URL, frame:kCMTimeZero, startPlaying: true);
                
                
            } else {
                self.videoPlayerViewController.VideoEditView.isHidden = true;
            }
            
            if(_extension == "JPG" || _extension == "jpg" || _extension == "DNG" || _extension == "dng" || _extension == "png" || _extension == "PNG") {
                
                self.editorTabViewController.selectedTabViewItemIndex = 2
                
                // nowPlayingFile.stringValue = item.name;
                var itemUrl = (item.url as URL).absoluteString
                itemUrl = itemUrl.replacingOccurrences(of: "file://", with: "")
                print("~~~~~~~~~~~~~~~~~~~~~~~ NOW SHOWING IMAGE: " + itemUrl)
                
                // self.imageEditorViewController.VideoEditView.isHidden = false;

                
                // HEY FUCKER YOU MUST SWITCH TABS FIRST OR THIS BREAKS!
                self.editorTabViewController.selectedTabViewItemIndex = 2

                self.imageEditorViewController.nowPlayingURL = (item.url as URL)
                self.imageEditorViewController.nowPlayingFile?.stringValue = item.name
                self.imageEditorViewController.nowPlayingURLString = itemUrl
                self.imageEditorViewController.loadImage(_url: item.url as URL)
                
            } else {
                // self.videoPlayerViewController.VideoEditView.isHidden = true;
            }
        }
    
    }
    
    func updateStatus() {
        
        let text: String
        
        // 1
        let itemsSelected = tableView.selectedRowIndexes.count
        
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
        loadItemFromTable()
        
        // 3
        statusLabel.stringValue = text
        // print("Selected Text : \(text)");
    }
    
    func tableViewDoubleClick(_ sender:AnyObject) {
        // 1
        guard tableView.selectedRow >= 0,
            let item = directoryItems?[tableView.selectedRow] else {
                return
        }
        
        if item.isFolder {
            // 2
            self.representedObject = item.url as Any
        }
        else {
            // 3
            NSWorkspace.shared().open(item.url as URL)
        }
    }
}

extension ViewController: NSTableViewDataSource {
    
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

extension ViewController: NSTableViewDelegate {
    
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

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

