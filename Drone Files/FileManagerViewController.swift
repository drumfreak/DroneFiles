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


class FileManagerViewController: NSViewController {
    
    @IBOutlet var topView: NSView!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var screenshotViewController: ScreenshotViewController!
    // @IBOutlet weak var editorViewController: EditorViewController!
    @IBOutlet weak var editorTabViewController: EditorTabViewController!
    @IBOutlet weak var imageEditorViewController: ImageEditorViewController!
    @IBOutlet weak var splitViewController: SplitViewController!
    
    // View controllers
    
    
    // Directories!
    var directory: Directory?
    var sourceFolder = "file:///Volumes/DroneStick1/DCIM/100MEDIA"
    
    var startingDirectory: URL!
    
    var currentDir: URL!
    var clippedDirectory: Directory?
    var directoryItems: [Metadata]?
    
    @IBOutlet var saveDirectoryName: String!
    @IBOutlet var folderURL: String!
    @IBOutlet weak var folderURLDisplay: NSTextField!
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
    var sortAscending = true

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController Loaded")
        self.startingDirectory = URL(string: self.sourceFolder)
        self.representedObject = self.startingDirectory
        
        tableView.delegate = self
        tableView.dataSource = self
        statusLabel.stringValue = ""
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))

        //videoView.
       //  self.showNotification(messageType: "default", customMessage: "");
        
        self.currentDir = self.startingDirectory
        
        // setupProjectDirectory()
        
        let descriptorName = NSSortDescriptor(key: Directory.FileOrder.Name.rawValue, ascending: true)
        let descriptorDate = NSSortDescriptor(key: Directory.FileOrder.Date.rawValue, ascending: false)
        let descriptorSize = NSSortDescriptor(key: Directory.FileOrder.Size.rawValue, ascending: true)
        
        tableView.tableColumns[0].sortDescriptorPrototype = descriptorName
        tableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
        tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
        
        self.representedObject = self.startingDirectory
        self.folderURL = self.startingDirectory?.absoluteString
  
        reloadFileList()
        
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
            self.startingDirectory = openPanel.url
            self.sourceFolder = (openPanel.url?.absoluteString)!
            
            let tmp = openPanel.url?.absoluteString.replacingOccurrences(of: "file://", with: "")
            self.folderURLDisplay.stringValue = (tmp!.replacingOccurrences(of: "%20", with: " "))
            // self.setupProjectDirectory()
        })
    }
    
    override var representedObject: Any? {
        didSet {
            if let url = representedObject as? URL {
                print("Represented object: \(url)")
                directory = Directory(folderURL: url)
                reloadFileList()
                self.folderURL = url.absoluteString
                // let tmp = url.absoluteString.replacingOccurrences(of: "file://", with: "")
                // print("TMP" + tmp)
                // self.folderURLDisplay.stringValue = tmp.replacingOccurrences(of: "%20", with: " ")
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
            print("CLICKED FOLDER");
            // self.currentDir = item.url as URL
            // self.representedObject = item.url as Any
        }
        else {
            
            // print("SELECTED ITEM IS \(item)");
            // 3
            
            let url = NSURL(fileURLWithPath: item.url.absoluteString)
            
            let _extension = url.pathExtension
            
            if(_extension == "MOV" || _extension == "mov" || _extension == "mp4" || _extension == "MP4" || _extension == "m4v" || _extension == "M4V") {
                
            }
            
            if(_extension == "JPG" || _extension == "jpg" || _extension == "DNG" || _extension == "dng" || _extension == "png" || _extension == "PNG") {
                
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
        //        // 1
        //        guard tableView.selectedRow >= 0,
        //            let item = directoryItems?[tableView.selectedRow] else {
        //                return
        //        }
        //
        //        if item.isFolder {
        //            // 2
        //            print("CLICKED FOLDER");
        //            self.representedObject = item.url as Any
        //            self.currentDir = item.url as URL
        //        }
        //        else {
        //            // 3
        //            NSWorkspace.shared().open(item.url as URL)
        //        }
    }
}

extension FileManagerViewController: NSTableViewDataSource {
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

extension FileManagerViewController: NSTableViewDelegate {
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



