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
    var title: String!

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

//            if((self.appDelegate.mediaQueueMonitorViewController?.viewIsLoaded)!) {
//               self.appDelegate.mediaQueueMonitorViewController?.startTimer()
//            }
        }
    }
    
//    override init() {
//        super.init()
//        self.appDelegate.mediaQueue = self
//
//    }

}

class MediaQueueMonitorViewController: NSViewController {

    @IBOutlet var window: NSWindow!
    @IBOutlet var queueItemsLabel: NSTextField!
    @IBOutlet weak var queueTimer: Timer!
    
    var  viewIsLoaded: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.mediaQueueMonitorViewController = self
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor
        self.window?.orderFront(self.view.window)
        self.window?.becomeFirstResponder()
        self.window?.titlebarAppearsTransparent = true
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.startTimer()
    }
    
    override func viewWillDisappear() {
        super.viewDidDisappear()
        self.viewIsLoaded = false
        self.stopTimer()
    }
    
    func getQueue() {
    }
    
    
    
    func startTimer() {
        
        if(self.appDelegate.mediaQueue.queue.count > 0) {
            if(self.queueTimer == nil) {
                print("~~~~~~~~~~~~~~~~ STARTING A TIMER")

                self.queueTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector:#selector(self.updateLabel), userInfo: nil, repeats: true)
                
                RunLoop.current.add(self.queueTimer, forMode: RunLoopMode.commonModes)
                
            } else {
                if(!self.queueTimer.isValid) {
                    print("~~~~~~~~~~~~~~~~ RESTARTING A TIMER")

                    self.queueTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.updateLabel), userInfo: nil, repeats: true)
                    
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
                print("Invalidating Timer")
                self.queueTimer.invalidate()
            }
        }
        
    }

    
    
    func updateLabel() {
        var i = 0
        
        print("WORKER ITEMS: \(self.appDelegate.mediaQueue.queue.count)")

        self.appDelegate.mediaQueue.queue.forEach({ worker in
            // print(String(describing: worker))
            print("\(i) TITLE : \(String(describing: worker.title))")

            print("\(i) URL : \(worker.outputUrl)")
            print("\(i) PERCENT : \(worker.percent)")
            print("\(i) InProgress : \(String(describing: worker.inProgress))")
            
            print("\(i) Status : \(String(describing: worker.workerStatus))")

            if(worker.percent == 1.0) {
                print("\(i)  REMOVING WORKER - Complete \(i)")
                self.appDelegate.mediaQueue.queue.remove(at: i)
                self.stopTimer()

                self.startTimer()
                return
            } else if(worker.inProgress == false) {
                print("\(i)  REMOVING WORKER - Not in progress \(i)")
                self.appDelegate.mediaQueue.queue.remove(at: i)
                self.stopTimer()

                self.startTimer()
                return
            }
            
            i += 1
            
        })

        if(self.appDelegate.mediaQueue.queue.count == 0) {
            self.stopTimer()
        }
        
    }
    

    

}
