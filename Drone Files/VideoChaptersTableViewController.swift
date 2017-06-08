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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.videoChaptersTableViewController = self
        self.tableView.delegate = self
        // Do view setup here
    }
    
    func reloadContents() {
        self.tableView?.reloadData()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsOpen = true
        self.tableView.reloadData()
    }
    
    
    override func viewDidDisappear() {
        super.viewDidAppear()
        self.viewIsOpen = false
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
                
                cell.removeChapterButton.tag = row
                
                // cell.queueOverAllProgressIndicator?.doubleValue = 0.0
                
                return cell
            }
            
        }
        return nil
    }
    
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        print("Selected: \(self.tableView.selectedRow)")
        
        if(tableView.selectedRow >= 0) {
            let chapter = self.appDelegate.videoDetailsViewController.chapters[self.tableView.selectedRow]
            
            print("Chapter... \(chapter)")
            self.appDelegate.videoPlayerViewController?.player.seek(to: CMTime(seconds: chapter.chapterStartTime, preferredTimescale: CMTimeScale(29.97)))
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func removeItem(sender: AnyObject) {
        Swift.print("remove ... \(sender.tag)")
        self.appDelegate.videoDetailsViewController.removeChapter(index: sender.tag)
        
    }
    
    @IBAction func exportItem(sender: AnyObject) {
        Swift.print("export... \(sender.tag)")
        self.appDelegate.videoDetailsViewController.exportChapter(index: sender.tag)
    }
    
}
