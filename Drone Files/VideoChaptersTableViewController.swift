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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.videoChaptersTableViewController = self
        self.tableView.delegate = self
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
                $0.chapterStartTime <= s && (($0.chapterEndTime) >=  s)
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
                
                cell.chapterTitle?.stringValue = "Chapter \(row + 1)"
                
                cell.chapterNumber?.title = "\(row + 1)"
                
                let (h,m,s,_) = self.appDelegate.secondsToHoursMinutesSeconds(seconds: Int(round(chapter.chapterStartTime)))
                
                cell.chapterStartTime?.stringValue = String(format: "%02d", h) + "h:" + String(format: "%02d", m) + "m:" + String(format: "%02d", s) + "s"
                
                
                if(chapter.chapterEndTime > -1) {
                    let (h1,m1,s1,_) = self.appDelegate.secondsToHoursMinutesSeconds(seconds: Int(round(chapter.chapterEndTime)))
                    
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
            self.appDelegate.videoDetailsViewController.currentChapter = chapter

            if(!self.blockPlayerSeek) {
                self.appDelegate.videoPlayerViewController?.player.seek(to: CMTime(seconds: (chapter.chapterStartTime), preferredTimescale: CMTimeScale((chapter.videoComp?.videoFile?.videoFPS)!)))
                
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
        // Initialization code
    }
    
    @IBAction func removeItem(sender: AnyObject) {
        Swift.print("REMOVE ... \(sender.tag)")
        self.appDelegate.videoDetailsViewController.removeChapter(index: sender.tag)
    }
    
    
    @IBAction func addRemoveFavorite(sender: AnyObject) {
        Swift.print("FAVORITE ... \(sender.tag)")
     self.appDelegate.videoDetailsViewController.addRemoveFavoriteChapter(index: sender.tag)
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
