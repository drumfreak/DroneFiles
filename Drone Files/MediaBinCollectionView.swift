//
//  ScreenShotSliderController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVFoundation

class MediaBinCollectionView: NSViewController {
    // View controllers
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var countLabel: NSButton!
    @IBOutlet var mediaShowIntervalSlider: NSSlider!
    @IBOutlet weak var startShowButton: NSButton!
    
    @IBOutlet weak var scrollView: ThemeScrollView!
    @IBOutlet var mediaShowRateLabel: NSTextField!
    @IBOutlet weak var mediaBinSlideshowTimer: Timer!
    @IBOutlet weak var reverseUrlsButton: NSButton!
    
    var slideshowPausedForVideo = false
    var splitItem: NSSplitViewItem!
    
    var viewConfigured = false
    var currentSlide = 0
    let mediaBinLoader = MediaBinLoader()
    
    var collectionViewLimit = 2500
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DispatchQueue.main.async {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appBackgroundColor.cgColor
        
        // }
        
        self.mediaShowIntervalSlider.doubleValue =  self.appSettings.mediaBinTimerInterval
        self.mediaShowRateLabel.doubleValue = self.appSettings.mediaBinTimerInterval
        
        // print(self.appSettings.mediaBinTimerInterval)
        if(self.appSettings.mediaBinUrls.count > 0) {
            self.reloadContents()
            self.selectItemOne()
        }
        
        
        self.appDelegate.mediaBinCollectionView = self
        //        self.collectionView.resignFirstResponder()
        //        self.resignFirstResponder()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.mediaShowIntervalSlider.doubleValue =  self.appSettings.mediaBinTimerInterval
        self.mediaShowRateLabel.doubleValue = self.appSettings.mediaBinTimerInterval
        // print(self.appSettings.mediaBinTimerInterval)
        
        self.countLabel.stringValue = "0"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
    }
    
    
    func selectItemOne() {
        self.selectItemByIndex(int: 0)
    }
    
    
    func selectItemByIndex(int: Int) {
        self.deselectAll();
        let indexPath = NSIndexPath.init(forItem: int, inSection: 0)
        DispatchQueue.main.async {
            let myIndexPath: Set = [indexPath as IndexPath]
            self.collectionView.scrollToItems(at: myIndexPath, scrollPosition: NSCollectionViewScrollPosition.top)
            
            self.collectionView.selectItems(at: Set([indexPath]) as Set<IndexPath>, scrollPosition: NSCollectionViewScrollPosition.left)
            
        }
        
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }
        let img = (item as! ScreenShotCollectionViewItem)
        
        let url = img.imageFile?.imgUrl

        if(self.appDelegate.isMov(file:url!)) {
            // Load video.
            
            if(self.appDelegate.appSettings.mediaBinSlideshowRunning) {
                self.stopTimerForVideo()
            }
            
            if(!self.appDelegate.appSettings.videoSplitViewIsOpen) {
                self.appDelegate.rightPanelSplitViewController?.showVideoSplitView()
            }
            
            // nowPlayingFile.stringValue = item.name;
            var itemUrl = url!.absoluteString
            itemUrl = itemUrl.replacingOccurrences(of: "file://", with: "")
            // print("~~~~~~~~~~~~~~~~~~~~~~~ NOW PLAYING: " + itemUrl)
            
            DispatchQueue.main.async {
                self.appDelegate.videoPlayerViewController?.VideoEditView.isHidden = false
                self.appDelegate.videoControlsController.nowPlayingFile?.stringValue = (url?.lastPathComponent)!
            }
            
            self.appDelegate.videoControlsController.currentVideoURL = url
            
            // self.appDelegate.videoPlayerViewController?.nowPlayingURL = (url)
            
            self.appDelegate.videoPlayerViewController?.playVideo(_url: url!, frame:kCMTimeZero, startPlaying: true);
            
            self.appDelegate.videoControlsController.nowPlayingURLString = itemUrl
            
            self.appDelegate.appSettings.lastFileOpened = url!.absoluteString
            self.appDelegate.secondaryDisplayMediaViewController?.loadVideo(videoUrl: url!)
        }
        
        
        if(self.appDelegate.isImage(file:(img.imageFile?.imgUrl)!)) {
            //  print(img.imageFile)
            if(self.appSettings.secondDisplayIsOpen) {
                // print("Displaying item on second screen...")
                self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: (img.imageFile?.imgUrl)!)
                self.appDelegate.imageEditorViewController?.loadImage(_url: (img.imageFile?.imgUrl)!)
                
            } else {
                
                if(!self.appDelegate.appSettings.imageEditorSplitViewIsOpen) {
                    self.appDelegate.rightPanelSplitViewController.showImageEditorSplitView()
                }
                
                self.appDelegate.imageEditorViewController?.loadImage(_url: (img.imageFile?.imgUrl)!)
            }
        }
        
        //DispatchQueue.main.async {
        (item as! ScreenShotCollectionViewItem).setHighlight(selected: true)
        // }
    }
    
    
    func reloadContents() {
        // mediaBinLoader.loadDataForFolderWithUrl(initialFolderUrl)
        
        if(self.appDelegate.appSettings.mediaBinUrls.count == 0) {
            return
        }
        var boo = [] as NSArray
        var foo = self.appDelegate.appSettings.mediaBinUrls as! NSMutableArray
    
        if(foo.count > self.collectionViewLimit) {
            boo = Array(foo.prefix(self.collectionViewLimit)) as NSArray
            foo = boo.mutableCopy() as! NSMutableArray
            
            
            print("REVERSED \(self.appDelegate.appSettings.mediaBinReverseURLS)")
            
            if(self.appDelegate.appSettings.mediaBinReverseURLS == true) {
                foo = foo.reversed() as! NSMutableArray
            }
            self.mediaBinLoader.loadDataFromUrls(foo)
            
            self.collectionView?.reloadData()
        } else {
            
            print("REVERSED \(self.appDelegate.appSettings.mediaBinReverseURLS)")
            
            if(self.appDelegate.appSettings.mediaBinReverseURLS == true) {
                foo = foo.reversed() as! NSMutableArray
            }
            
            self.mediaBinLoader.loadDataFromUrls(foo)
            self.collectionView?.reloadData()
        }
        
        //DispatchQueue.main.async {
        //NSAnimationContext.runAnimationGroup({context in
        //    context.duration = 1.0
            self.configureCollectionView()
            
        //}) {
        //}
        //}
        
        
        DispatchQueue.main.async {
            self.countLabel.title = String(format: "%1d", self.appSettings.mediaBinUrls.count)
        }
        self.collectionView?.resignFirstResponder()
        self.resignFirstResponder()
    }
    
    
    
    
    @IBAction func clearMediaBin (_ sender : AnyObject) {
        self.appDelegate.appSettings.mediaBinUrls.removeAll(keepingCapacity: false)
        self.reloadContents()
    }
    
    @IBAction func reverseUrls (_ sender : AnyObject) {
        self.appDelegate.appSettings.mediaBinReverseURLS = !self.appDelegate.appSettings.mediaBinReverseURLS
        self.reloadContents()
    }
    
    @IBAction func startMediaShow (_ sender : AnyObject) {
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        
        if(self.appSettings.mediaBinSlideshowRunning == true) {
            self.stopTimer()
            DispatchQueue.main.async {
                //stringValue = "Start Show"
                let myAttribute = [NSForegroundColorAttributeName: NSColor.highlightColor,
                                   NSParagraphStyleAttributeName: paragraph]

                
                let myAttrString = NSAttributedString(string:"Start Show", attributes: myAttribute)
                
                self.startShowButton.attributedTitle = myAttrString
            

            }
        } else {
            self.startTimer()
            DispatchQueue.main.async {
                
                let myAttribute = [NSForegroundColorAttributeName: NSColor.blue,
                                   NSParagraphStyleAttributeName: paragraph]
                
                let myAttrString = NSAttributedString(string:"Stop Show", attributes: myAttribute)
                self.startShowButton.attributedTitle = myAttrString
                //stringValue = "Start Show"
            }
            
        }
        
    }
    
    func nextSlideAfterVideo() {
        if(self.appSettings.mediaBinSlideshowRunning) {
            self.nextSlide()
            self.startTimer()
        }
    }
    
    
    @IBAction func mediaShowRateSliderChanged(_ sender: NSSlider) {
        
        DispatchQueue.main.async {
            self.appDelegate.appSettings.mediaBinTimerInterval = sender.doubleValue
            
            self.mediaShowRateLabel.doubleValue = sender.doubleValue
        }
        
        if(self.appSettings.mediaBinSlideshowRunning && !self.slideshowPausedForVideo) {
            self.stopTimer()
            self.startTimer()
        }
    }
    
    
    
    private func configureCollectionView() {
        if(!self.viewConfigured) {
            // 1
            let flowLayout = NSCollectionViewFlowLayout()
            flowLayout.itemSize = NSSize(width: 80.0, height: 70.0)
            flowLayout.sectionInset = EdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
            flowLayout.minimumInteritemSpacing = 10.0
            flowLayout.minimumLineSpacing = 10.0
            
            DispatchQueue.main.async {
                self.collectionView?.collectionViewLayout = flowLayout
                // 2
                self.view.wantsLayer = true
                // 3
                self.collectionView?.layer?.backgroundColor = self.appSettings.appBackgroundColor.cgColor
                self.viewConfigured = true
            }
        }
    }
    
    
    func startTimer() {
        self.slideshowPausedForVideo = false
        self.appDelegate.appSettings.mediaBinSlideshowRunning = true
        // DispatchQueue.global().async() {
        self.mediaBinSlideshowTimer = Timer.scheduledTimer(timeInterval: self.appSettings.mediaBinTimerInterval, target: self, selector:#selector(self.nextSlide), userInfo: nil, repeats: true)
        
        RunLoop.current.add(self.mediaBinSlideshowTimer, forMode: RunLoopMode.commonModes)
        
        // }
        
    }
    
    func stopTimer() {
        if(self.appDelegate.videoPlayerViewController?.player.isPlaying)! {
            self.appDelegate.videoPlayerViewController?.player.pause()
        }
        if(self.mediaBinSlideshowTimer != nil) {
            if(self.mediaBinSlideshowTimer.isValid) {
                print("Invalidating Timer")
                // RunLoop.current.add(self.whatTheFucktimer, forMode: RunLoopMode.commonModes)
                self.mediaBinSlideshowTimer.invalidate()
                self.appDelegate.appSettings.mediaBinSlideshowRunning = false
                self.mediaBinSlideshowTimer = nil
            }
        }
    }
    
    func stopTimerForVideo() {
        self.slideshowPausedForVideo = true
        if(self.mediaBinSlideshowTimer != nil) {
            if(self.mediaBinSlideshowTimer.isValid) {
                print("Stopping Timer for Video")
                // RunLoop.current.add(self.whatTheFucktimer, forMode: RunLoopMode.commonModes)
                self.mediaBinSlideshowTimer.invalidate()
                self.mediaBinSlideshowTimer = nil
            }
        }
        
    }
    
    
    func nextSlide() {
        
        let count = self.collectionView.numberOfItems(inSection: 0)
        
        print("Count: \(count)")
        
        if(self.currentSlide > -1 && ((self.currentSlide + 1) < self.collectionViewLimit) && ((self.currentSlide + 1) < count)) {
            if(self.currentSlide >= count) {
                self.currentSlide = 0
            } else {
                self.currentSlide += 1
            }
        } else {
            self.currentSlide = 0
        }
        
        if(count > 0) {
            DispatchQueue.main.async {
                
                print("Slide: \(self.currentSlide)")
                
                self.selectItemByIndex(int: self.currentSlide)
                // self.collectionView.reloadData()
            }
        }
        
        
        
    }
    
    
    @IBAction func hideScreenshotSlider (_ sender : AnyObject) {
        // print("Fuck")
        // self.view.isHidden = true
        self.splitItem = self.appDelegate.rightPanelSplitViewController?.splitViewItem(for: self)!
        if(self.splitItem != nil) {
            if(self.splitItem.isCollapsed) {
                self.appDelegate.mediaBinCollectionView.reloadContents()
                self.unHideMediaBin()
            } else {
                self.hideMediaBin()
            }
        }
    }
    
    func hideMediaBin() {
        self.splitItem = self.appDelegate.rightPanelSplitViewController?.splitViewItem(for: self)!
        self.splitItem.isCollapsed = true
        // self.splitItem.holdingPriority = 250
        // self.appDelegate.rightPanelSplitViewController.splitView.adjustSubviews()
        
    }
    
    func unHideMediaBin() {
        self.splitItem = self.appDelegate.rightPanelSplitViewController?.splitViewItem(for: self)!
        self.splitItem.isCollapsed = false
        self.splitItem.holdingPriority = 250
        self.appDelegate.rightPanelSplitViewController.splitView.adjustSubviews()
        
    }
    
    
    @IBAction func showScreenshotSlider (_ sender : AnyObject) {
        // print("Fuck")
        // self.view.isHidden = true
        
        //  foo.isCollapsed = false
        // self.appDelegate.rightPanelSplitViewController.splitView.adjustSubviews()
    }
    
    func deselectAll() {
        self.collectionView.deselectAll(nil)
    }
}


extension MediaBinCollectionView : NSCollectionViewDataSource {
    
    // 1
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return mediaBinLoader.numberOfSections
    }
    
    // 2
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaBinLoader.numberOfItemsInSection(section)
    }
    
    // 3
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        
        // 4
        let item = collectionView.makeItem(withIdentifier: "ScreenShotCollectionViewItem", for: indexPath as IndexPath)
        guard let collectionViewItem = item as? ScreenShotCollectionViewItem else {
        
            return item
        }
        
        // 5
        let imageFile = mediaBinLoader.imageFileForIndexPath(indexPath as IndexPath)
        
        DispatchQueue.main.async {
            collectionViewItem.imageFile = imageFile
        }
        
        // self.currentSlide    = collectionView.row
        self.slideshowPausedForVideo = false
        
        if let selectedIndexPath = collectionView.selectionIndexPaths.first, selectedIndexPath == indexPath {
            
            DispatchQueue.main.async {
                collectionViewItem.setHighlight(selected: true)
            }
        } else {
            DispatchQueue.main.async {
                collectionViewItem.setHighlight(selected: false)
            }
        }
        
        
        return item
    }
    
}

extension MediaBinCollectionView : NSCollectionViewDelegate {
    // 1
    
    internal func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        // 3
        guard let item = collectionView.item(at: indexPath as IndexPath) as? ScreenShotCollectionViewItem else {
            return
        }
        
        self.currentSlide = indexPath.item
        
        // Load image...
        let url = item.imageFile?.imgUrl
        
        self.slideshowPausedForVideo = false

        if(self.appDelegate.isMov(file:url!)) {
            // Load video.
            
            if(self.appDelegate.appSettings.mediaBinSlideshowRunning) {
               
                self.stopTimerForVideo()
            }
            
            if(!self.appDelegate.appSettings.videoSplitViewIsOpen) {
                self.appDelegate.rightPanelSplitViewController?.showVideoSplitView()
            }
            
            var itemUrl = url!.absoluteString
            itemUrl = itemUrl.replacingOccurrences(of: "file://", with: "")
            
            DispatchQueue.main.async {
                self.appDelegate.videoPlayerViewController?.VideoEditView.isHidden = false
                self.appDelegate.videoControlsController.nowPlayingFile?.stringValue = (url?.lastPathComponent)!
            }

            self.appDelegate.videoControlsController.currentVideoURL = url
            self.appDelegate.videoPlayerViewController?.nowPlayingURL = (url)
            self.appDelegate.videoControlsController.nowPlayingURLString = itemUrl
            self.appDelegate.appSettings.lastFileOpened = url!.absoluteString
            self.appDelegate.secondaryDisplayMediaViewController?.loadVideo(videoUrl: url!)
        }
        
        
        if(self.appDelegate.isImage(file:(item.imageFile?.imgUrl)!)) {
            if(self.appDelegate.appSettings.mediaBinSlideshowRunning) {
                if(self.mediaBinSlideshowTimer == nil) {
                    self.startTimer()
                }
            }

            
            if(self.appSettings.secondDisplayIsOpen) {
                self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: (item.imageFile?.imgUrl)!)
                self.appDelegate.imageEditorViewController?.loadImage(_url: (item.imageFile?.imgUrl)!)
            } else {
                if(!self.appDelegate.appSettings.imageEditorSplitViewIsOpen) {
                    self.appDelegate.rightPanelSplitViewController.showImageEditorSplitView()
                }
                
                self.appDelegate.imageEditorViewController?.loadImage(_url: (item.imageFile?.imgUrl)!)
            }
            
            DispatchQueue.main.async {
                item.setHighlight(selected: true)
            }
        }
        
    }
    
    
    private func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        // 2
        //
        //        guard let indexPath = indexPaths.first else {
        //            return
        //        }
        //        // 3
        //        guard let item = collectionView.item(at: indexPath as IndexPath) else {
        //            return
        //        }
        //
        //        self.currentSlide = indexPath.item
        
        
        //        let img = (item as! ScreenShotCollectionViewItem)
        //
        //        if(self.appSettings.secondDisplayIsOpen) {
        //            //DispatchQueue.main.async {
        //                //print("Displaying item on second screen...")
        //                self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: (img.imageFile?.imgUrl)!)
        //                self.appDelegate.imageEditorViewController?.loadImage(_url: (img.imageFile?.imgUrl)!)
        //            //}
        //
        //        } else {
        //            //DispatchQueue.main.async {
        //            if( self.appDelegate.editorTabViewController?.selectedTabViewItemIndex != 1) {
        //                self.appDelegate.editorTabViewController?.selectedTabViewItemIndex = 1
        //            }
        //                self.appDelegate.imageEditorViewController?.loadImage(_url: (img.imageFile?.imgUrl)!)
        //            //}
        //        }
        //        DispatchQueue.main.async {
        //            (item as! ScreenShotCollectionViewItem).setHighlight(selected: true)
        //        }
    }
    
    // 4
    
    internal func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        
        guard let indexPath = indexPaths.first else {
            return
        }
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }
        
        // self.currentSlide = indexPath.item
        
        DispatchQueue.main.async {
            (item as! ScreenShotCollectionViewItem).setHighlight(selected: false)
        }
        
    }
    
    
    private func collectionView(collectionView: NSCollectionView, didDeselectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }
        //        let img = (item as! ScreenShotCollectionViewItem)
        //
        //        self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: (img.imageFile?.imgUrl)!)
        
        DispatchQueue.main.async {
            (item as! ScreenShotCollectionViewItem).setHighlight(selected: false)
        }
    }
    
}
