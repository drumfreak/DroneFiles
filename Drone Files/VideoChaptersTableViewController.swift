//
//  VideoChapterTableViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 6/8/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//


import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz
import CoreData

class VideoChaptersTableViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView!
    var viewIsOpen = false
    var blockPlayerSeek = false
    var disabledOffset = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.videoChaptersTableViewController = self
        self.tableView.delegate = self
        self.tableView.backgroundColor = self.appSettings.tableRowBackGroundColor
        // Do view setup here
    }
    

    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsOpen = true
        DispatchQueue.main.async {
            self.reloadContents()
        }
    }
    
    
    override func viewDidDisappear() {
        super.viewDidAppear()
        self.viewIsOpen = false
    }
    
    func reloadContents() {
        self.tableView?.reloadData()
        self.selectCurrentChapter()
    }
    
    func selectCurrentChapter() {
        
        if(!(self.appDelegate.videoPlayerViewController?.playerIsReady)!) {
            return
        }
        if(self.viewIsOpen) {
            let s = Double((self.appDelegate.videoPlayerViewController?.player.currentTime().seconds)!)
            
            let chap = self.appDelegate.videoDetailsViewController.chapters.first(where: {
                $0.compositionStartTime <= s && (($0.compositionEndTime) >=  s)
            })
            
            guard let _ = chap?.chapterName! else {
                return
            }
            
            self.blockPlayerSeek = true
            self.appDelegate.videoDetailsViewController.blockChapterLoad = true
            let i =  self.appDelegate.videoDetailsViewController.chapters.index(of: chap!)
            
            let f = IndexSet.init(integer: i!)
            
            self.tableView.selectRowIndexes(f, byExtendingSelection: false)
        }

        
    }
}



extension VideoChaptersTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.appDelegate.videoDetailsViewController.chapters.count
    }
    
}

extension VideoChaptersTableViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if(tableView.numberOfRows >= 1) {
            
            // 3
            if let cell = tableView.make(withIdentifier: "videoChapterCell", owner: nil) as? VideoChapterTableCellView {
                
                let chapter = self.appDelegate.videoDetailsViewController.chapters[row]
                
                if(!chapter.chapterEnabled) {
                    self.disabledOffset += chapter.chapterLength
                    print("")
                    print("")
                    print("DISABLED OFFSET IS NOW: \(self.disabledOffset)")
                    print("")
                    print("")
                }
                
                cell.chapterTitle?.stringValue = "Chapter \(row + 1)"
                
                cell.chapterNumber?.title = "\(row + 1)"
                
                let (h,m,s,_) = self.appDelegate.secondsToHoursMinutesSeconds(seconds: Int(round(chapter.compositionStartTime)))
                
                cell.chapterStartTime?.stringValue = String(format: "%02d", h) + "h:" + String(format: "%02d", m) + "m:" + String(format: "%02d", s) + "s"
                
                
                if(chapter.chapterEndTime > -1) {
                    let (h1,m1,s1,_) = self.appDelegate.secondsToHoursMinutesSeconds(seconds: Int(round(chapter.compositionEndTime)))
                    
                    cell.chapterEndTime?.stringValue = String(format: "%02d", h1) + "h:" + String(format: "%02d", m1) + "m:" + String(format: "%02d", s1) + "s"
                    
                }
                
                if(chapter.chapterLength > -1) {
                    let (h2,m2,s2,_) = self.appDelegate.secondsToHoursMinutesSeconds(seconds: Int(round(chapter.chapterLength)))
                    
                    cell.chaptureDuration?.stringValue = String(format: "%02d", h2) + "h:" + String(format: "%02d", m2) + "m:" + String(format: "%02d", s2) + "s"
                    
                }
                
                if(chapter.isFavorite) {
                    cell.favoriteButton?.image = NSImage.init(named: "heart-table-active.png")
                } else {
                    cell.favoriteButton?.image = NSImage.init(named: "heart-table-inactive.png")
                }
                
                if(chapter.chapterEnabled) {
                   // cell.enableDisableButton?.image = NSImage.init(named: "heart-table-active.png")
                    cell.enableDisableButton.state = 1
                } else {
                    // cell.enableDisableButton?.image = NSImage.init(named: "heart-table-inactive.png")
                    cell.enableDisableButton.state = 0
                }
                
                if((chapter.thumbnail) != nil) {
                    cell.chapterThumbnail.image = NSImage.init(data: (chapter.thumbnail?.data! as Data?)!)
                } else {

                    cell.chapterThumbnail.isHidden = true
                }
                
                cell.removeChapterButton.tag = row
                cell.favoriteButton.tag = row
                cell.enableDisableButton.tag = row
                cell.exportButton.tag = row

                // cell.queueOverAllProgressIndicator?.doubleValue = 0.0
                
                return cell
            }
            
        }
        return nil
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        // print("Selected: \(self.tableView.selectedRow)")
        
        self.appDelegate.videoDetailsViewController.blockChapterLoad = true
    
        if(self.appDelegate.videoPlayerViewController?.player.isPlaying)! {
            self.appDelegate.videoPlayerViewController?.playPause()
        }
        
        if(tableView.selectedRow >= 0) {
            let chapter = self.appDelegate.videoDetailsViewController.chapters[self.tableView.selectedRow]
            if(chapter.chapterEnabled == false) {
                return
            }
            
            self.appDelegate.videoDetailsViewController.currentChapter = chapter

            if(!self.blockPlayerSeek) {
                
                var i = 0
                var offset = 0.00
                
                self.appDelegate.videoDetailsViewController.chapters.forEach({ chap in
                    if(i <= self.tableView.selectedRow) {
                        
                        if(!chap.chapterEnabled) {
                            offset += chap.chapterLength

                        }
                    }
                    i += 1
                })
                
                print("OFFSET: \(offset)")
                
                self.appDelegate.videoPlayerViewController?.player.seek(to: CMTime(seconds: (chapter.compositionStartTime - offset), preferredTimescale: CMTimeScale((chapter.videoComp?.videoFile?.videoFPS)!)))
                
                if(!(self.appDelegate.videoPlayerViewController?.player.isPlaying)!) {
                    self.appDelegate.videoPlayerViewController?.playPause()
                }
                
                self.blockPlayerSeek = false
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.appDelegate.videoDetailsViewController.blockChapterLoad = false
                }

            } else {
                self.blockPlayerSeek = false
                if(!(self.appDelegate.videoPlayerViewController?.player.isPlaying)!) {
                    self.appDelegate.videoPlayerViewController?.playPause()
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                    self.appDelegate.videoDetailsViewController.blockChapterLoad = false
                }
            }
            var scroll = self.tableView.selectedRow
            if(self.tableView.selectedRow > 8 && (self.tableView.numberOfRows > self.tableView.selectedRow + 1)) {
                scroll = self.tableView.selectedRow + 1
            }
            self.tableView.scrollRowToVisible(scroll)
            //print("Chapter... \(chapter)")
        }
        
        // Table row colors
        var i = Int(0)
        
        while(i < self.tableView.numberOfRows) {
            if(i < 0) {
                return
            }
            let rowView = self.tableView.rowView(atRow: i, makeIfNecessary: true)
            let f = self.tableView.selectedRowIndexes.index(of: i)
            if((f) != nil) {
                rowView?.backgroundColor = self.appDelegate.appSettings.tableRowSelectedBackGroundColor
            } else {
                if(i % 2 == 0) {
                    rowView?.backgroundColor = self.appDelegate.appSettings.tableRowBackGroundColor
                } else {
                    rowView?.backgroundColor = self.appDelegate.appSettings.tableViewAlternatingRowColor
                }
            }
            
            i += 1
        }
        
        if(self.tableView.selectedRow >= 0) {
            let rowView = self.tableView.rowView(atRow: self.tableView.selectedRow, makeIfNecessary: true)
            
            // Current row selected color
            rowView?.backgroundColor = self.appDelegate.appSettings.tableRowActiveDarkBlueBackGroundColor
        }
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return ThemeTableRowView()
    }
    
    

    
}



class VideoChapterTableCellView: NSTableCellView {
    
    @IBOutlet var view: NSView!
    @IBOutlet var chapterTitle: NSTextField!
    @IBOutlet var chapterStartTime: NSTextField!
    @IBOutlet var chapterEndTime: NSTextField!
    @IBOutlet var chaptureDuration: NSTextField!
    
    @IBOutlet var removeChapterButton: NSButton!
    @IBOutlet var chapterNumber: NSButton!
    @IBOutlet var favoriteButton: NSButton!
    @IBOutlet var enableDisableButton: NSButton!
    @IBOutlet var exportButton: NSButton!
    
    @IBOutlet var chapterThumbnail: NSImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func removeItem(sender: AnyObject) {
        Swift.print("REMOVE ... \(sender.tag)")
        self.appDelegate.videoDetailsViewController.removeChapter(index: sender.tag)
    }
    
    
    @IBAction func addRemoveFavorite(sender: AnyObject) {
        Swift.print("FAVORITE ... \(sender.tag)")
        if(self.appDelegate.videoDetailsViewController.addRemoveFavoriteChapter(index: sender.tag) == true) {
            self.favoriteButton?.image = NSImage.init(named: "heart-table-active.png")
        } else {
            self.favoriteButton?.image = NSImage.init(named: "heart-table-inactive.png")
        }
        
    }
    
    @IBAction func exportItem(sender: AnyObject) {
        Swift.print("EXPORT... \(sender.tag)")
        self.appDelegate.videoDetailsViewController.exportChapter(index: sender.tag)
    }
    
    @IBAction func enableDisableChapter(sender: AnyObject) {
        Swift.print("ENABLE/DISABLE ... \(sender.tag)")
        self.appDelegate.videoDetailsViewController.enableDisableChapter(index: sender.tag)
    }
    
}
