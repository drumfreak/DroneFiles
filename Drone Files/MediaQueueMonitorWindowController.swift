//
//  MediaQueueMonitorWindowController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/30/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class MediaQueueMonitorWindowController: NSWindowController {
    override var windowNibName: String? {
        return "MediaQueueMonitorWindowController" // no extension .xib here
    }
}

class MediaQueueMonitorWindow: NSWindow {
    @IBOutlet weak var toolBar: NSToolbar!
}


class MediaQueueWorkerItem: NSObject {
    
    var workerStatus: Bool!
    var percent = 0.0
    var errorMessage = ""
    var outputUrl: URL!
    var inProgress: Bool!
    var failed = false
    var title: String!
    var originalFileDateUrl: URL?

    override init() {
        super.init()
    }
}

class MediaQueue: NSObject {
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    var queue = [MediaQueueWorkerItem]() {
        didSet {
            print("Hey I added a fucking media queue worker!")
            print("Media Queue: \([queue.last])")
            print("Media Item: \([queue.last?.title])")
            self.appDelegate.mediaQueueMonitorViewController?.refreshQueue()
        }
    }
}


class MediaQueueMonitorViewController: NSViewController {

    @IBOutlet var window: NSWindow!
    @IBOutlet var queueItemsLabel: NSTextField!
    @IBOutlet weak var queueTimer: Timer!
    @IBOutlet var queuePercentLabel: NSTextField!
    @IBOutlet var queueOverAllProgressIndicator: NSProgressIndicator!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var scrollView: NSScrollView!
    var lastQueueCount = 0
    var queueTotalStatus = 0

    var  viewIsLoaded: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.mediaQueueMonitorViewController = self
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.appViewBackgroundColor
        self.queueItemsLabel.stringValue = "0 items"
        self.queuePercentLabel.stringValue = "0%"
        self.tableView.backgroundColor = self.appSettings.appViewBackgroundColor
        self.scrollView.wantsLayer = true
        self.scrollView.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.appViewBackgroundColor
        self.window?.orderFront(self.view.window)
        self.window?.becomeFirstResponder()
        self.window?.titlebarAppearsTransparent = true
        self.tableView.reloadData()
        
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.startTimer()
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.viewIsLoaded = false
        self.stopTimer()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.viewIsLoaded = false
        self.stopTimer()
    }

    func refreshQueue() {
        if(self.viewIsLoaded)! {
            self.stopTimer()
            self.tableView.reloadData()
            if(self.viewIsLoaded)! {
                self.startTimer()
            }
        }
    }
    
    func getQueue() {
        
    }
    
    
    func runQueue() {
        
        if(self.appDelegate.mediaQueue.queue.count > 0) {

        }
    }
    
    
    func startTimer() {
        if(self.appDelegate.mediaQueue.queue.count > 0) {
            if(self.queueTimer == nil) {
               // print("~~~~~~~~~~~~~~~~ STARTING A TIMER")

                self.queueTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector:#selector(self.updateLabel), userInfo: nil, repeats: true)
                
                RunLoop.current.add(self.queueTimer, forMode: RunLoopMode.commonModes)
                
            } else {
                if(!self.queueTimer.isValid) {
                 //   print("~~~~~~~~~~~~~~~~ RESTARTING A TIMER")

                    self.queueTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector:#selector(self.updateLabel), userInfo: nil, repeats: true)
                    
                    RunLoop.current.add(self.queueTimer, forMode: RunLoopMode.commonModes)
                }
            }
        } else {
            print("Queue is empty... not starting timer...")
        }
    }
    
    
    func stopTimer() {
        
        // self.appDelegate.appSettings.mediaBinSlideshowRunning = false
        if(self.queueTimer != nil) {
            if(self.queueTimer.isValid) {
                print("Invalidating queue Timer")
                self.queueTimer.invalidate()
                self.queueTimer = nil
            }
        }
    }

    
    
    func updateLabel() {
        var i = 0
        var activeWorkers = 0
        var queueTotal = 0.00
        
        
        // print("WORKER ITEMS: \(self.appDelegate.mediaQueue.queue.count)")
        
       
        self.appDelegate.mediaQueue.queue.forEach({ worker in
            //  print(String(describing: worker))
            //            print("\(i) TITLE : \(String(describing: worker.title))")
            //
            //            print("\(i) URL : \(worker.outputUrl)")
            //            print("\(i) PERCENT : \(worker.percent)")
            //            print("\(i) InProgress : \(String(describing: worker.inProgress))")
            //            
            // print("\(i) Status : \(String(describing: worker.workerStatus))")
                        
            
            if(self.tableView.numberOfRows >= i) {
                
                let rowView = self.tableView.rowView(atRow: i, makeIfNecessary: false)
                
                let cell = rowView?.view(atColumn: 0) as! MediaQueueMonitorTableCellView
                
                DispatchQueue.main.async {
                    cell.queueTitleLabel.stringValue = worker.title
                    cell.queueFileNameLabel.stringValue = worker.outputUrl.lastPathComponent.replacingOccurrences(of: "%20", with: " ")
                    
                    cell.queueOverAllProgressIndicator.doubleValue = worker.percent
                    
                    cell.queuePercentLabel.stringValue = String(format: "%.0f", worker.percent) + "%"
                    
                }

            }
            
            
            
            if(worker.percent == 100.0) {
                print("\(i)  REMOVING WORKER - Complete \(i)")
                self.stopTimer()
                self.appDelegate.mediaQueue.queue.remove(at: i)
                if(self.tableView.numberOfRows >= i) {
                    self.tableView.removeRows(at: NSIndexSet(index: i) as IndexSet, withAnimation:NSTableViewAnimationOptions.slideUp)
                }
                self.startTimer()


                return
            } else if(worker.inProgress == false) {
                print("\(i)  REMOVING WORKER - Not in progress \(i)")
                
                self.stopTimer()
                self.appDelegate.mediaQueue.queue.remove(at: i)
                // let fcu =
                
                if(self.tableView.numberOfRows >= i) {

                    
                    self.tableView.removeRows(at: NSIndexSet(index: i) as IndexSet, withAnimation:NSTableViewAnimationOptions.slideUp)

                }
                self.startTimer()

                return
            } else if(worker.failed) {
                print("\(i)  REMOVING WORKER - FAILED WORKER \(i)")
                self.stopTimer()

                self.appDelegate.mediaQueue.queue.remove(at: i)
                
    
                if(self.tableView.numberOfRows >= i) {

                    self.tableView.removeRows(at: NSIndexSet(index: i) as IndexSet, withAnimation:NSTableViewAnimationOptions.slideUp)
                }
                
                
                self.startTimer()
                
                return

                
            }
            
            i += 1
            
            queueTotal += worker.percent
            
            activeWorkers += 1

            
            let percent = queueTotal / Double(i)
            self.queueOverAllProgressIndicator.doubleValue = percent
            self.queuePercentLabel.stringValue = String(format: "%.0f", percent) + "%"
            
            if(self.appDelegate.mediaQueue.queue.count != self.lastQueueCount) {
                // Queue changed.
                DispatchQueue.main.async {

                self.tableView.reloadData()

                self.stopTimer()
                self.tableView.reloadData()
                
                self.lastQueueCount = self.appDelegate.mediaQueue.queue.count
                
                self.startTimer()
                
                }
            }

            
        })
        DispatchQueue.main.async {
            self.queueItemsLabel.stringValue = "\(self.appDelegate.mediaQueue.queue.count) Items"

        }
        
        if(self.appDelegate.mediaQueue.queue.count == 0) {
            self.stopTimer()
            
//            DispatchQueue.main.async {
//                // self.tableView.reloadData()
//            }
            
        }
        
    }
}

extension MediaQueueMonitorViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.appDelegate.mediaQueue.queue.count
    }
    
}

extension MediaQueueMonitorViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
//        let cellNib = NSNib(nibNamed: "MediaQueueMonitorTableCellViewController", bundle: Bundle.main)
//        
//        self.tableView.register(cellNib, forIdentifier: "mediaQueueProgress")
//        
//
        if(tableView.numberOfRows >= 1) {

            // 3
            if let cell = tableView.make(withIdentifier: "mediaQueueProgress", owner: nil) as? MediaQueueMonitorTableCellView {
                cell.queueTitleLabel?.stringValue = ""
                cell.queuePercentLabel?.stringValue = ""
                cell.queueFileNameLabel?.stringValue = ""
                cell.queueOverAllProgressIndicator?.doubleValue = 0.0
            
                return cell
            }
            
        }
        return nil

    }
    
    
}
