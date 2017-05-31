//
//  TimeLapseViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/27/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit
import AppKit
import Quartz


class TimeLapseViewController: NSViewController, NSUserNotificationCenterDelegate {

    var notificationCenter: NSUserNotificationCenter!

    @IBOutlet var numberofFilesLabel: NSButton!
    @IBOutlet var saveTimeLapseButton: NSButton!
    @IBOutlet var durationLabel: NSTextField!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    
    @IBOutlet var videoSizeSelectMenu: NSPopUpButton!
    @IBOutlet var videoFrameRateSelectMenu: NSPopUpButton!
    @IBOutlet var outputFolderLabel: NSTextField!
    @IBOutlet var outputFileName: NSTextField!
    @IBOutlet var progressLabel: NSTextField!
    var mediaQueueMonitorWindowController: MediaQueueMonitorWindowController!

    
    var videoSizeSelectMenuOptions = [
                                        "[16:9] - 1024×576",
                                        "[16:9] - 1152×648",
                                        "[16:9] - 1280 x 720 (720HD)",
                                        "[16:9] - 1366×768",
                                        "[16:9] - 1600×900",
                                        "[16:9] - 1920 x 1080 (1080HD)",
                                        "[16:9] - 2560 x 1440 (1440HD)",
                                        "[16:9] - 3840 x 2160 (4k)",
                                        "[16:9] - 7680 x 4320 (8k)",
        
                                        "[4:3] - 640×480",
                                        "[4:3] - 800×600",
                                        "[4:3] - 960×720",
                                        "[4:3] - 1024×768",
                                        "[4:3] - 1280×960",
                                        "[4:3] - 1400×1050",
                                        "[4:3] - 1440×1080",
                                        "[4:3] - 1600×1200",
                                        "[4:3] - 1856×1392",
                                        "[4:3] - 1920×1440",
                                        "[4:3] - 2048×1536",
        
                                        "[16:10] - 1280×800",
                                        "[16:10] - 1440×900",
                                        "[16:10] - 1680×1050",
                                        "[16:10] - 1920×1200",
                                        "[16:10] - 2560×1600"
                                    ]
    
    
    var videoSizes: [NSSize] = [
        NSSize(width: 1024, height: 576),
        NSSize(width: 1152, height: 648),
        NSSize(width: 1280, height: 720),
        NSSize(width: 1366, height: 768),
        NSSize(width: 1600, height: 900),
        NSSize(width: 1920, height: 1080),
        NSSize(width: 2560, height: 1440),
        NSSize(width: 3840, height: 2160),
        NSSize(width: 7680, height: 4320),
        NSSize(width: 640, height: 480),
        NSSize(width: 800, height: 600),
        NSSize(width: 960, height: 720),
        NSSize(width: 1024, height: 768),
        NSSize(width: 1280, height: 960),
        NSSize(width: 1400, height: 1050),
        NSSize(width: 1440, height: 1080),
        NSSize(width: 1600, height: 1200),
        NSSize(width: 1856, height: 1392),
        NSSize(width: 1920, height: 1440),
        NSSize(width: 2048, height: 1536),
        NSSize(width: 1280, height: 800),
        NSSize(width: 1440, height: 900),
        NSSize(width: 1680, height: 1050),
        NSSize(width: 1920, height: 1200),
        NSSize(width: 2560, height: 1600)
    ]

    
    var videoFrameRateSelectMenuOptions = ["1", "2", "5", "10", "15", "20", "24", "30", "60", "120"]
    
    
    var frameRates = [1, 2, 5, 10, 15, 20, 24, 30, 60, 120]
    
    var timelapseVideoName = ""
    
    var imageUrls = [String]()

    var imageTimings = [Float]()
    
    var viewIsLoaded = false
    
    var receivedFiles = NSMutableArray() {
        didSet {
            if(self.viewIsLoaded) {
                self.numberofFilesLabel.title = "\"(receivedFiles.count)"
              
                if(receivedFiles.count > 2) {
                    self.saveTimeLapseButton.isEnabled = true
                } else {
                    self.saveTimeLapseButton.isEnabled = false
                }
                
                self.prepareImageURLs()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            let count = String(format: "%1d", receivedFiles.count)
            self.numberofFilesLabel.title = count
        
        self.notificationCenter = NSUserNotificationCenter.default
        
        self.notificationCenter.delegate = self
        
        DispatchQueue.main.async {
            self.progressIndicator.isHidden = true
            if(self.receivedFiles.count > 2) {
                self.saveTimeLapseButton.isHidden = false
            }
        }
        
        self.videoSizeSelectMenu.addItems(withTitles: self.videoSizeSelectMenuOptions)
        
        self.videoSizeSelectMenu.selectItem(at: 5)
        
        self.videoFrameRateSelectMenu.addItems(withTitles: self.videoFrameRateSelectMenuOptions)
        
        self.videoFrameRateSelectMenu.selectItem(at: 3)


        self.outputFolderLabel.stringValue = self.appSettings.timeLapseFolder.replacingOccurrences(of: self.appSettings.projectFolder, with: "").replacingOccurrences(of: "%20", with: " ").replacingOccurrences(of: "/Volumes", with: "")
        
        self.progressLabel.isHidden = true
        self.progressLabel.stringValue = "0%"
        self.getTimeLapseUrl()

    }

    func getTimeLapseUrl() {
        
        let framerate = self.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]
        
        let size = self.videoSizes[self.videoSizeSelectMenu.indexOfSelectedItem]
        
        //print("size \(String(describing: size))")
        
        //print("framerate \(String(describing: framerate))")
    
        let sizeAndWidth =  "\(Int32(size.width))x\(Int32(size.height))-\(framerate)fps"
        
        let _ = self.generateTimeLapseURL(sizeAndWidth: sizeAndWidth)
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsLoaded = true
        let count = String(format: "%1d", receivedFiles.count)
        self.numberofFilesLabel.title = count
        
        // self.generateTimeLapse(self)
        
         prepareImageURLs()

    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        self.viewIsLoaded = false
        // self.deallocObservers()
    }
    
    func prepareImageURLs() {
        // var currentTime = CMTimeMakeWithSeconds(0, 30)
        self.imageUrls.removeAll()
       
        self.receivedFiles.forEach({m in
            let urlPath = m as! String
            let url = URL(string: urlPath)
            if(self.appDelegate.isImage(file: url!)) {
                self.imageUrls.append(urlPath)
            }
        })
    }

    func finishSave(_ err: Bool, url: URL) {
        DispatchQueue.main.async {
            self.saveTimeLapseButton.isEnabled = true
            self.progressIndicator.isHidden = true
            self.progressIndicator.doubleValue = 0.00
            self.progressLabel.stringValue = "0.0%"
            self.progressLabel.isHidden = true
            if(!err) {
                self.appDelegate.appSettings.mediaBinUrls.append(url)
                
                let notification = NSUserNotification()

                if(self.imageUrls.count > 0) {
                    notification.contentImage = NSImage(contentsOf: URL(string: self.imageUrls[0])!)
                }
                
                
                
                notification.identifier = "timelapse29sdfsdf0239\(UUID().uuidString)"
                notification.title = "Timelapse Saved!"
                notification.informativeText = "Filename.... "
                notification.soundName = NSUserNotificationDefaultSoundName
                notification.notificationUrl = url.absoluteString
                notification.hasActionButton = true
                notification.actionButtonTitle = "View"
                // notification.otherButtonTitle = "Dismiss"

                notification.setValue(true, forKey: "_showsButtons")
                
                var actions = [NSUserNotificationAction]()
                
                let action1 = NSUserNotificationAction(identifier: "viewNow", title: url.absoluteString)
                
                let action2 = NSUserNotificationAction(identifier: "openInFinder", title: "Open in Quicktime")
                
                let action3 = NSUserNotificationAction(identifier: "eatMe", title: "Something else")
                
                actions.append(action1)
                actions.append(action2)
                actions.append(action3)
                
                notification.additionalActions = actions

                self.notificationCenter.deliver(notification)
    
            } else {
                
                let myPopup: NSAlert = NSAlert()
                
                myPopup.messageText = "Timelapse Failed"
                myPopup.informativeText = "Something went wrong. Dispatching Monkeys to find out why."
                myPopup.alertStyle = NSAlertStyle.warning
                myPopup.addButton(withTitle: "OK")
                myPopup.runModal()

            }
        }
    }
    
    
    
    @IBAction func writeTimeLapse(_ sender: AnyObject) {
        
        //print("rate: \(String(describing: self.videoFrameRateSelectMenu.indexOfSelectedItem))")
   
        print("This is being called....")
        
        
        self.saveTimeLapseButton.isEnabled = false
        
        self.progressIndicator.isHidden = false
        
        self.progressIndicator.doubleValue = 0.00
        
        self.progressLabel.isHidden = false
        
        self.progressLabel.stringValue = "0%"

       

        let framerate = self.frameRates[self.videoFrameRateSelectMenu.indexOfSelectedItem]
        
        let size = self.videoSizes[self.videoSizeSelectMenu.indexOfSelectedItem]
    
        let sizeAndWidth =  "\(Int32(size.width))x\(Int32(size.height))-\(framerate)fps"
        
        let timeLapseUrl = self.generateTimeLapseURL(sizeAndWidth: sizeAndWidth)
        
        let timeLapseUrls = NSArray(array:self.imageUrls, copyItems: true)
        
        let workerItem: MediaQueueWorkerItem!
        
        workerItem = MediaQueueWorkerItem()
        
        let timeLapseWorkerItem = DispatchWorkItem {
            
            workerItem.inProgress = true
            workerItem.outputUrl = URL(string: timeLapseUrl)
            workerItem.title = workerItem.outputUrl.lastPathComponent.replacingOccurrences(of: "%20", with: " ")
            

            let builder = TimeLapseBuilder(photoURLs: timeLapseUrls as! [String], url: timeLapseUrl)
        
            print("New Timelapse video file..." + (URL(string: timeLapseUrl)?.lastPathComponent)!)
        
            builder.build(frameRate: Int32(framerate), outputSize: size, { progress in
                    // print(progress.fractionCompleted)
                    workerItem.inProgress = true
                    workerItem.percent = (progress.fractionCompleted * 100.0)
                }, success: { url in
                    // print(url)
                    workerItem.outputUrl = url
                    // self.finishSave(false, url: url)
                    workerItem.workerStatus = true
                    workerItem.inProgress = false
                }, failure: { error in
                    print("ERROR \(error)")
                    
                    // workerItem.workerStatus = false
                    // workerItem.inProgress = false
                    // self.finishSave(true, url: URL(string: timeLapseUrl)!)
                })
            
            
        }
    

        timeLapseWorkerItem.perform()
        
        let queue = DispatchQueue.global(qos: .utility)
        
        queue.async(execute: timeLapseWorkerItem)
        
        timeLapseWorkerItem.notify(queue: DispatchQueue.main) {
            self.appDelegate.mediaQueue.queue.append(workerItem)

            // print("percent = ", percent)
            print("Worker launched... ")
        }
        
        
//        if(!self.appDelegate.appSettings.mediaQueueIsOpen) {
//            self.mediaQueueMonitorWindowController = MediaQueueMonitorWindowController()
//            
//            self.mediaQueueMonitorWindowController?.showWindow(self)
//            
//        }

        
       
        
        
        
////            DispatchQueue.main.async {
////               // self.progressLabel.stringValue = String(format: "%.2f", percent) + "%"
////                
////                self.progressIndicator.doubleValue = progress.fractionCompleted
////                
////            }
////            
//        }


    }
    
    // Video Clipping
    func getClippedVideosIncrement(folder: String) -> String {
        var incrementer = "00"
        var isDirectory: ObjCBool = false
        var foo = URL(string:folder)?.absoluteString.replacingOccurrences(of: "file://", with: "")
        
        foo = foo?.replacingOccurrences(of: "%20", with: " ")
        
        if FileManager.default.fileExists(atPath: foo!, isDirectory: &isDirectory) {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.appDelegate.appSettings.timeLapseFolder)!, includingPropertiesForKeys: nil, options: [])
                if(files.count > 0) {
                    incrementer = String(format: "%02d", files.count)
                }
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func generateTimeLapseURL(sizeAndWidth: String) -> String {
  
        let increment = getClippedVideosIncrement(folder: self.appDelegate.appSettings.timeLapseFolder)
        
        self.timelapseVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Timelapse \(increment) - \(sizeAndWidth).mp4"
    
        let timelapseFullPath = self.appDelegate.appSettings.timeLapseFolder + "/" + self.timelapseVideoName.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: timelapseFullPath.replacingOccurrences(of: "file://", with: "")) {
            print("Fuck that file exists..")
            
            let incrementer = "00000"
           
            self.timelapseVideoName = self.appDelegate.appSettings.saveDirectoryName + " - Timelapse \(increment) - \(incrementer) - \(sizeAndWidth).mp4"
            
        } else {
            print("That file does not exist..")
        }
        
        let timeLapseUrl = self.appDelegate.appSettings.timeLapseFolder + "/" + self.timelapseVideoName.replacingOccurrences(of: " ", with: "%20")
        
        self.outputFileName.stringValue = URL(string: timeLapseUrl)!.lastPathComponent
        
       //  print("So far I came up with: \(timeLapseUrl)")

        return timeLapseUrl.replacingOccurrences(of: " ", with: "%20")
    }
    
    func setFileDate(originalFile: String, newDate: Date) {
        // print("ORIGINAL FILE.... \(originalFile)")
        
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        
        original = original.replacingOccurrences(of: "%20", with: " ");
        
        do {
            
            let attributes = [
                FileAttributeKey.creationDate: newDate,
                FileAttributeKey.modificationDate: newDate
            ]
            
            do {
                try FileManager.default.setAttributes(attributes, ofItemAtPath: original)
            } catch {
                print(error)
            }
        }
    }

    
    // Notifications
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
     
        
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        switch (notification.activationType) {

        case .actionButtonClicked:
            self.appDelegate.fileBrowserViewController.sourceFolderOpened = URL(string: self.appDelegate.appSettings.timeLapseFolder)
            
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: notification.notificationUrl!)
            
        case .contentsClicked:
            self.appDelegate.fileBrowserViewController.sourceFolderOpened = URL(string: self.appDelegate.appSettings.timeLapseFolder)
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: notification.notificationUrl!)
        default:
            break
        }
    }
}
