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
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var screenshotViewController: ScreenshotViewController!
    // @IBOutlet weak var editorViewController: EditorViewController!
    @IBOutlet weak var editorTabViewController: EditorTabViewController!
    @IBOutlet weak var imageEditorViewController: ImageEditorViewController!
    @IBOutlet weak var splitViewController: SplitViewController!
    @IBOutlet weak var fileBrowserViewController: FileBrowserViewController!
    
    var fileList: FileManagerList?
    
    @IBOutlet var organizeButton: NSButton!
    @IBOutlet var renameButton: NSButton!
    @IBOutlet var copyButton: NSButton!
    @IBOutlet var deleteButton: NSButton!
    @IBOutlet var moveButton: NSButton!
    @IBOutlet var tableView: NSTableView!
    
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
        
        print("~~~~~~~ Showing Table View")
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
        
        // print("File URLS \(self.fileURLs)")
        reloadFileList()
        
        
        print("Selecting All")
        
        
        // tableView.reloadData()
    }
    
    override func viewWillAppear() {
        self.viewIsLoaded = true
        print ("~ View is about to appear")
    }
    
    override func viewDidDisappear() {
        self.viewIsLoaded = false
        print ("~~~~~~~~~~~~ View Disappeared")
        
    }
    
    func reloadFileList() {
        
        if let files = fileURLs as? NSMutableArray {
            print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~File List Updated")
            self.fileList = FileManagerList(fileArray: files)
            self.fileItems = fileList?.contentsOrderedBy(sortOrder, ascending: sortAscending)
            if(self.viewIsLoaded) {
               //  tableView.selectAll(self)
                
                tableView.reloadData()
                tableView.selectAll(self)
                
            }

        }

        
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
            print("CLICKED FOLDER");
            NSWorkspace.shared().open(item.url as URL)
            //self.representedObject = item.url as Any
            // self.currentDir = item.url as URL
        }
        else {
            // 3
            NSWorkspace.shared().open(item.url as URL)
        }
    }
    
    
    
    @IBAction func organizeFiles(_ sender: AnyObject) {
        print("Organize Files Button Clicked")
        let manageFileURLS: NSMutableArray = []
        let manageFileMovies: NSMutableArray = []
        let manageFileScreenshots: NSMutableArray = []
        let manageFileJPG: NSMutableArray = []
        let manageFileRAW: NSMutableArray = []
        let manageFileOther: NSMutableArray = []
        
        if(tableView.selectedRowIndexes.count > 0) {
            for (_, index) in tableView.selectedRowIndexes.enumerated() {
                guard index >= 0,
                    let item = fileItems?[index] else {
                        return
                }
                print("SELECTED ITEMS \(item.url)")
                manageFileURLS.add(item.url)
                
                let url = NSURL(fileURLWithPath: item.url.absoluteString)
                
                let _extension = url.pathExtension
                var skip = false
                
                // item.index = index
                
                if(_extension == "MOV" || _extension == "mov" || _extension == "mp4" || _extension == "MP4" || _extension == "m4v" || _extension == "M4V") {
                    manageFileMovies.add(item)
                    skip = true
                }
                
                if(_extension == "JPG" || _extension == "jpg" ) {
                    manageFileJPG.add(item)
                    skip = true
                }
                
                if(_extension == "DNG" || _extension == "dng" ||  _extension == "RAW" ||  _extension == "raw") {
                    manageFileJPG.add(item)
                    skip = true
                }
                
                if(_extension == "png" || _extension == "PNG") {
                    manageFileScreenshots.add(item)
                    skip = true
                }
                
                if(!skip) {
                    manageFileOther.add(item)
                }
            }
            
            
            if(manageFileMovies.count > 0) {
                if(checkFolderAndCreate(folderPath: self.fileBrowserViewController.videoFolder)) {
                    print("VIDEOS FOLDER: \(self.fileBrowserViewController.videoFolder)")
                    manageFileMovies.forEach({ m in
                        let movie = (m as! FileListMetadata)
                        //print(movie)
                        self.organizeMovieFile(url: (movie.url))
                        self.reloadFileList()
                    })
                }
            }
            
            if(manageFileJPG.count > 0) {
                if(checkFolderAndCreate(folderPath: self.fileBrowserViewController.jpgFolder)) {
                    manageFileJPG.forEach({ m in
                        let file = (m as! FileListMetadata)
                        self.organizeJPGFile(url: (file.url))
                    })
                }
            }
            
            if(manageFileScreenshots.count > 0) {
                if(checkFolderAndCreate(folderPath: self.fileBrowserViewController.screenShotFolder)) {
                    manageFileScreenshots.forEach({ m in
                        let file = (m as! FileListMetadata)
                        self.organizeScreenShotFile(url: (file.url))
                    })
                }
            }
            
            if(manageFileRAW.count > 0) {
                if(checkFolderAndCreate(folderPath: self.fileBrowserViewController.rawFolder)) {
                    manageFileRAW.forEach({ m in
                        let file = (m as! FileListMetadata)
                        self.organizeRawFile(url: (file.url))
                    })
                }
            }
            
            //showNotification(messageType: "OrganizeFiles", customMessage: "No Files Selected!")
            showAlert(text: "Files Organized!", body: "The files have been organized!", showCancel: false, messageType: "warning")
            
            showNotification(messageType: "OrganizeFiles", customMessage: self.fileBrowserViewController.videoFolder)
            var f = self.fileURLs as! Array<Any>?
            
            manageFileURLS.forEach({ m in
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
            
        } else {
            //showNotification(messageType: "OrganizeFiles", customMessage: "No Files Selected!")
            showAlert(text: "No Files Selected!", body: "Select files from the File Manager List and try again.", showCancel: false, messageType: "warning")
        }
    }
    
    @IBAction func renameFiles(_ sender: AnyObject) {
        // print("Rename Button Clicked")
    }
    
    @IBAction func copyFiles(_ sender: AnyObject) {
        // print("Copy Files Button Clicked")
    }
    
    @IBAction func moveFiles(_ sender: AnyObject) {
        // print("Moved Button Clicked")
    }
    
    @IBAction func deleteFiles(_ sender: AnyObject) {
        // print("Delete Button Clicked")
    }
    
    func organizeMovieFile(url: URL) {
        print("Organizing MOVIE ... \(url)")
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.videoFolder)
        
        var newMovieFile = self.fileBrowserViewController.videoFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".MOV" // for now
        
        newMovieFile = newMovieFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newMovieFile)!)) {
            print("Succes... file moved");
            self.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
        }
        
    }
    
    func organizeJPGFile(url: URL) {
        print("Organizing JPG ... \(url)")
        
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.jpgFolder)
        
        var newJPGFile = self.fileBrowserViewController.jpgFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".jpg" // for now
        
        newJPGFile = newJPGFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newJPGFile)!)) {
            print("Succes... file moved");
            self.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
        }
    }
    
    func organizeScreenShotFile(url: URL) {
        print("Organizing Screenshot ... \(url)")
        
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.screenShotFolder)
        
        var newScreenshotFile = self.fileBrowserViewController.screenShotFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".png" // for now
        
        newScreenshotFile = newScreenshotFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newScreenshotFile)!)) {
            print("Succes... file moved");
            self.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
        }
    }
    
    func organizeRawFile(url: URL) {
        print("Organizing RAW ... \(url)")
        
        let increment =  getFileIncrementAtPath(path: self.fileBrowserViewController.screenShotFolder)
        
        var newRawFile = self.fileBrowserViewController.screenShotFolder + "/" + self.fileBrowserViewController.fileSequenceName + " - " + increment + ".dng" // for now
        
        newRawFile = newRawFile.replacingOccurrences(of: " ", with: "%20")
        if(self.moveFile(from: url, toUrl: URL(string: newRawFile)!)) {
            print("Succes... file moved");
            self.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
        }
    }
    
    
    func organizeOtherFile(url: URL) {
        print("Organizing Other ... \(url)")
        
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
    
    
}
func showNotification(messageType: String, customMessage: String) -> Void {
    DispatchQueue.global(qos: .userInitiated).async {
        if(messageType == "OrganizeFiles") {
            // DispatchQueue.main.async {
            // print("Message Type VIDEO TRIM COMPLETE: " + messageType);
            let notification = NSUserNotification()
            notification.title = "Organization Complete"
            notification.informativeText = customMessage.replacingOccurrences(of: "%20", with: " ")
            
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
            // cell.selectAll(<#T##sender: Any?##Any?#>)
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        updateStatus()
    }
    
}



