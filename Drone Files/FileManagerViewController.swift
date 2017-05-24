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
    
    // View controllers
    
    @IBOutlet weak var statusLabel: NSTextField!
    
    
    var fileList: FileManagerList?
    
    @IBOutlet var organizeButton: NSButton!
    @IBOutlet var renameButton: NSButton!
    @IBOutlet var copyButton: NSButton!
    @IBOutlet var deleteButton: NSButton!
    @IBOutlet var moveButton: NSButton!
    @IBOutlet var tableView: NSTableView!
    
    @IBOutlet var organizeOptionsView: NSTextField!
    
    var viewIsLoaded = false
    
    var fileItems: [FileListMetadata]?
    let sizeFormatter = ByteCountFormatter()
    var sortOrder = FileManagerList.FileOrder.Name
    var sortAscending = true
    
    var fileURLs: Any? {
        didSet {
            self.reloadFileList()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // print("~~~~~~~ Showing Table View")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        statusLabel.stringValue = ""
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
        
        let descriptorName = NSSortDescriptor(key: FileManagerList.FileOrder.Name.rawValue, ascending: true)
        let descriptorDate = NSSortDescriptor(key: FileManagerList.FileOrder.Date.rawValue, ascending: false)
        let descriptorSize = NSSortDescriptor(key: FileManagerList.FileOrder.Size.rawValue, ascending: true)
        
        tableView.tableColumns[0].sortDescriptorPrototype = descriptorName
        tableView.tableColumns[1].sortDescriptorPrototype = descriptorDate
        tableView.tableColumns[2].sortDescriptorPrototype = descriptorSize
        reloadFileList()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.viewIsLoaded = true
        self.appDelegate.screenShotSliderController.hideMediaBin()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.appDelegate.screenShotSliderController.hideMediaBin()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.viewIsLoaded = false
        self.appDelegate.screenShotSliderController.unHideMediaBin()
    }
    
    func reloadFileList() {
        if let files = fileURLs as? NSMutableArray {
            // print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~File List Updated")
            self.fileList = FileManagerList(fileArray: files)
            self.fileItems = fileList?.contentsOrderedBy(sortOrder, ascending: sortAscending)
            if(self.viewIsLoaded) {
                //  tableView.selectAll(self)
                tableView.reloadData()
                tableView.selectAll(self)
                self.updateStatus()
            }
        }
    }
    
    
    func calculateFileSizesFromDestination(fileUrls: Array<Any>) -> NSMutableDictionary {
        var totalSize = Int64(0)
        var totalFiles = 0
        
        let returnDetails = NSMutableDictionary()
        
        
        fileUrls.forEach({ m in
            let urlPath = m as! String
            let url = URL(string: urlPath)
            var attributes = NSMutableDictionary()
            let path = getPathFromURL(path: (url?.absoluteString)!)
            
            do {
                try attributes = FileManager.default.attributesOfItem(atPath: path) as! NSMutableDictionary
                // print(attributes)
                
                
                print("FILE SIZE : \(String(describing: attributes["NSFileSize"]))")
                totalSize += attributes["NSFileSize"] as! Int64
                totalFiles += Int(1)
            } catch _ as NSError {
                // do nothing...
            }
        })
        
        returnDetails["totalSize"] = totalSize
        returnDetails["totalFiles"] = totalFiles
        return returnDetails
    }
    
    func calculateFileSizesToDestination(fileUrls: Array<Any>) -> NSMutableDictionary {
        var totalSize = 0
        var totalFiles = 0
        
        let returnDetails = NSMutableDictionary()
        
        fileUrls.forEach({ m in
            let urlPath = m as! String
            let url = URL(string: urlPath)
            var attributes = NSMutableDictionary()
            let path = getPathFromURL(path: (url?.absoluteString)!)
            
            do {
                try attributes = FileManager.default.attributesOfItem(atPath: path) as! NSMutableDictionary
                // print(attributes)
                
                // print("FILE SIZE : \(String(describing: attributes["NSFileSize"]))")
                totalSize += attributes["NSFileSize"] as! Int
                totalFiles += Int(1)
            } catch _ as NSError {
                // do nothing...
            }
        })
        
        returnDetails["totalSize"] = totalSize
        returnDetails["totalFiles"] = totalFiles
        return returnDetails
    }
    
    func calculateSingleFileSize(fileUrl: String) -> NSMutableDictionary {
        var totalSize = Int64(0)
        var totalFiles = Int64(0)
        
        let returnDetails = NSMutableDictionary()
        
        let urlPath = fileUrl
        let url = URL(string: urlPath)
        var attributes = NSMutableDictionary()
        let path = getPathFromURL(path: (url?.absoluteString)!)
        
        
        do {
            try attributes = FileManager.default.attributesOfItem(atPath: path) as! NSMutableDictionary
            print(attributes)
            
            // print("FILE SIZE : \(String(describing: attributes["NSFileSize"]))")
            totalSize += attributes["NSFileSize"] as! Int64
            totalFiles += Int64(1)
            
            print("Calculating size for \(String(describing: path))")
            print("Calculating size for \(totalSize)")
            
        } catch _ as NSError {
            // do nothing...
        }
        
        returnDetails["totalSize"] = totalSize
        returnDetails["totalFiles"] = totalFiles
        return returnDetails
    }
    
    
    
    func bytesToHuman(size: Int64) -> String {
        let countBytes = ByteCountFormatter()
        countBytes.allowedUnits = [.useMB]
        countBytes.countStyle = .file
        let fileSize = countBytes.string(fromByteCount: Int64(size))
        return fileSize
    }
    
    func loadItemFromTable() {
        // print("SELECTED ROW \(self.tableView.selectedRow)")
        // 1
        let f = fileItems!.count
        
        if(tableView.selectedRow > f) {
            return
        }
        
        guard tableView.selectedRow >= 0,
            let item = fileItems?[tableView.selectedRow] else {
                return
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
        if (fileItems == nil) {
            text = "No Items"
        }
        else if(itemsSelected == 0) {
            text = "\(fileItems!.count) items"
        }
        else {
            text = "\(itemsSelected) of \(fileItems!.count) selected"
            let sendFilesToControllers = NSMutableArray()
            
            if(tableView.selectedRowIndexes.count > 0) {
                for (_, index) in tableView.selectedRowIndexes.enumerated() {
                    guard index >= 0,
                        let item = fileItems?[index] else {
                            return
                    }
                    
                    sendFilesToControllers.add(item.url.absoluteString)
                    
                }
                
                self.appDelegate.fileManagerOptionsTabViewController?.receivedFiles = sendFilesToControllers
            }
        }
        loadItemFromTable()
        
        // 3
        statusLabel.stringValue = text
    }
    
    func tableViewDoubleClick(_ sender:AnyObject) {
        // 1
        guard tableView.selectedRow >= 0,
            let item = fileItems?[tableView.selectedRow] else {
                return
        }
        
        if item.isFolder {
            // 2
            // print("CLICKED FOLDER");
            NSWorkspace.shared().open(item.url as URL)
            //self.representedObject = item.url as Any
            // self.currentDir = item.url as URL
        }
        else {
            // 3
            NSWorkspace.shared().open(item.url as URL)
        }
    }
    
    func resetTableAfterFileOperation(fileArray: NSMutableArray) {
        var f = self.fileURLs as! Array<Any>?
        // print("Hey reloading!!!!!!!!!!!!!!!!!!!!!");
        
        
        fileArray.forEach({ m in
            let foo2 = m as! URL
            f = f?.filter() {
                let foo = $0 as! URL
                return foo.absoluteString != foo2.absoluteString
            }
        })
        
        let newArray = NSMutableArray()
        
        f?.forEach({ m in
            newArray.add(m)
        })
        
        self.fileURLs = newArray
        self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
        
    }
    
    func showNotification(messageType: String, customMessage: String) -> Void {
        DispatchQueue.global(qos: .userInitiated).async {
            if(messageType == "OrganizeFiles") {
                let notification = NSUserNotification()
                notification.title = "Organization Complete"
                notification.informativeText = customMessage.replacingOccurrences(of: "%20", with: " ")
                
                notification.soundName = NSUserNotificationDefaultSoundName
                NSUserNotificationCenter.default.deliver(notification);
            }
            
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier == "fileOptionsTabSegue" {
            self.appDelegate.fileManagerOptionsTabViewController = segue.destinationController as! FileManagerOptionsTabViewController
            
            self.appDelegate.fileManagerViewController = self
        }
    }
    
    func getPathFromURL(path: String) -> String {
        var path = path.replacingOccurrences(of: "file://", with: "")
        path = path.replacingOccurrences(of: "%20" , with: " ")
        return path
    }
    
    
    
    
    func shareMultipleFiles(receivedFiles: Array<Any>, s: AnyObject?) {
        let shareItems: NSMutableArray = []
        receivedFiles.forEach({ m in
            let urlPath = m as! String
            let url = NSURL(string: urlPath)
            shareItems.add(url!)
        })
        
        if(shareItems.count > 0) {
            let picker = NSSharingServicePicker.init(items: shareItems as! [Any])
            
            picker.show(relativeTo: s!.bounds, of: s as! NSView, preferredEdge: NSRectEdge.minY)
            
        }
    }
    
}
extension FileManagerViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fileItems?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        // 1
        guard let sortDescriptor = tableView.sortDescriptors.first else {
            return
        }
        if let order = FileManagerList.FileOrder(rawValue: sortDescriptor.key!) {
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
        
        if(fileItems?.count == 0) {
            return nil
        }
        // 1
        guard let item = fileItems?[row] else {
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


extension NSOpenPanel {
    var selectUrl: URL? {
        title = "Select File"
        allowsMultipleSelection = false
        canChooseDirectories = true
        canChooseFiles = false
        canCreateDirectories = false
        //allowedFileTypes = ["jpg","png","pdf","pct", "bmp", "tiff"]  // to allow only images, just comment out this line to allow any file type to be selected
        return runModal() == NSFileHandlingPanelOKButton ? urls.first : nil
    }
}


