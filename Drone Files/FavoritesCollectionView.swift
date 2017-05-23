//
//  FavoritesCollectionViewController
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa


class FavoritesCollectionViewController: NSViewController {
    // View controllers
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var countLabel: NSButton!
    @IBOutlet var mediaShowIntervalSlider: NSSlider!
    @IBOutlet weak var startShowButton: NSButton!
    
    @IBOutlet weak var scrollView: ThemeScrollView!
    @IBOutlet var mediaShowRateLabel: NSTextField!
    @IBOutlet weak var mediaBinSlideshowTimer: Timer!
    
    var viewConfigured = false
    var currentSlide = 0
    let mediaBinLoader = MediaBinLoader()
    
    
    func loadDataForNewFolderWithUrl(_ folderURL: URL) {
        mediaBinLoader.loadDataForFolderWithUrl(folderURL)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countLabel.stringValue = "0"
        
        self.appDelegate.favoritesCollectionViewController = self
        self.reloadContents()
        
        self.selectItemOne()
        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appBackgroundColor.cgColor
        
        self.mediaShowIntervalSlider.doubleValue =  self.appDelegate.appSettings.mediaBinTimerInterval
        
        self.mediaShowRateLabel.doubleValue = self.appDelegate.appSettings.mediaBinTimerInterval
        
    }
    
    
    func selectItemOne() {
        let path = NSIndexPath.init(forItem: 0, inSection: 0)
        self.collectionView.selectItems(at: Set([path]) as Set<IndexPath>, scrollPosition: NSCollectionViewScrollPosition.top)
    }
    
    
    func selectItemByIndex(int: Int) {
        let indexPath = NSIndexPath.init(forItem: int, inSection: 0)
        
        self.collectionView.selectItems(at: Set([indexPath]) as Set<IndexPath>, scrollPosition: NSCollectionViewScrollPosition.top)
        
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }
        let img = (item as! ScreenShotCollectionViewItem)
        
        
        //  print(img.imageFile)
        
        if(self.appSettings.secondDisplayIsOpen) {
            //print("Displaying item on second screen...")
            self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: (img.imageFile?.imgUrl)!)
        } else {
            self.appDelegate.editorTabViewController?.selectedTabViewItemIndex = 1
            self.appDelegate.imageEditorViewController?.loadImage(_url: (img.imageFile?.imgUrl!)!)
        }
        
        (item as! ScreenShotCollectionViewItem).setHighlight(selected: true)
        
    }
    
    
    func reloadContents() {
        
        // mediaBinLoader.loadDataForFolderWithUrl(initialFolderUrl)
        
        // var boo = [] as NSArray
        var foo = self.appDelegate.appSettings.favoriteUrls as! NSMutableArray
        foo = foo.reversed() as! NSMutableArray
        
        //        if(foo.count > 10) {
        //            boo = Array(foo.prefix(10)) as NSArray
        //            foo = boo.mutableCopy() as! NSMutableArray
        //
        //            mediaBinLoader.loadDataFromUrls(foo)
        //        } else {
        //   }
        
        
        self.mediaBinLoader.loadDataFromUrls(foo)
        
        self.configureCollectionView()
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            
            
            self.countLabel.title = String(format: "%1d", self.appSettings.favoriteUrls.count)
        }
        
        //self.collectionView.resignFirstResponder()
        //self.resignFirstResponder()
        // }
    }
    
    
    
    
    @IBAction func clearMediaBin (_ sender : AnyObject) {
        self.appDelegate.appSettings.favoriteUrls.removeAll(keepingCapacity: false)
        self.reloadContents()
    }
    
    
    @IBAction func startMediaShow (_ sender : AnyObject) {
        //  self.appDelegate.appSettings.mediaBinUrls.removeAll(keepingCapacity: false)
        
        // self.reloadContents()
        
        if(self.appSettings.mediaBinSlideshowRunning == true) {
            self.stopTimer()
            self.startShowButton.stringValue = "Start Show"
        } else {
            self.startTimer()
            self.startShowButton.stringValue = "Stop Show"
            
        }
        
    }
    
    @IBAction func mediaShowRateSliderChanged(_ sender: NSSlider) {
        // let slider = sender as! NSSlider
        print(sender.doubleValue)
        self.appDelegate.appSettings.mediaBinTimerInterval = sender.doubleValue
        
        self.mediaShowRateLabel.doubleValue = sender.doubleValue
        
        if(self.appSettings.mediaBinSlideshowRunning) {
            self.stopTimer()
            self.startTimer()
        }
    }
    
    
    private func configureCollectionView() {
        
        if(!self.viewConfigured) {
            
            // 1
            let flowLayout = NSCollectionViewFlowLayout()
            flowLayout.itemSize = NSSize(width: 80.0, height: 70.0)
            flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
            flowLayout.minimumInteritemSpacing = 20.0
            flowLayout.minimumLineSpacing = 20.0
            self.collectionView.collectionViewLayout = flowLayout
            // 2
            view.wantsLayer = true
            // 3
            self.collectionView.layer?.backgroundColor = self.appSettings.appBackgroundColor.cgColor
            self.viewConfigured = true
        }
    }
    
    
    func startTimer() {
        
        self.appDelegate.appSettings.mediaBinSlideshowRunning = true
        
        self.currentSlide = 0
        
        // DispatchQueue.global().async() {
        self.mediaBinSlideshowTimer = Timer.scheduledTimer(timeInterval: self.appSettings.mediaBinTimerInterval, target: self, selector:#selector(self.nextSlide), userInfo: nil, repeats: true)
        
        RunLoop.current.add(self.mediaBinSlideshowTimer, forMode: RunLoopMode.commonModes)
        
        // }
        
    }
    
    func stopTimer() {
        self.appDelegate.appSettings.mediaBinSlideshowRunning = false
        if(self.mediaBinSlideshowTimer != nil) {
            if(self.mediaBinSlideshowTimer.isValid) {
                print("Invalidating Timer")
                // RunLoop.current.add(self.whatTheFucktimer, forMode: RunLoopMode.commonModes)
                self.mediaBinSlideshowTimer.invalidate()
            }
        }
        
    }
    
    func nextSlide() {
        
        print("Hey next slide!")
        
        self.currentSlide += 1
        
        if(self.currentSlide >= self.appDelegate.appSettings.mediaBinUrls.count) {
            
            self.currentSlide = 0
        }
        
        print("Selecting : i \(self.currentSlide)")
        
        DispatchQueue.main.async {
            
            self.selectItemByIndex(int: self.currentSlide)
            
            self.collectionView.reloadData()
            
        }
        
        
    }
}


extension FavoritesCollectionViewController : NSCollectionViewDataSource {
    
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
        guard let collectionViewItem = item as? ScreenShotCollectionViewItem else {return item}
        
        // 5
        let imageFile = mediaBinLoader.imageFileForIndexPath(indexPath as IndexPath)
        collectionViewItem.imageFile = imageFile
        
        
        if let selectedIndexPath = collectionView.selectionIndexPaths.first, selectedIndexPath == indexPath {
            collectionViewItem.setHighlight(selected: true)
        } else {
            collectionViewItem.setHighlight(selected: false)
        }
        
        
        return item
    }
    
}

extension FavoritesCollectionViewController : NSCollectionViewDelegate {
    // 1
    
    
    internal func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        // 3
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }
        let img = (item as! ScreenShotCollectionViewItem)
        
        
        //  print(img.imageFile)
        
        self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: (img.imageFile?.imgUrl)!)
        
        (item as! ScreenShotCollectionViewItem).setHighlight(selected: true)
        
    }
    
    
    private func collectionView(collectionView: NSCollectionView, didSelectItemsAtIndexPaths indexPaths: Set<NSIndexPath>) {
        // 2
        guard let indexPath = indexPaths.first else {
            return
        }
        // 3
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }
        let img = (item as! ScreenShotCollectionViewItem)
        
        self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: (img.imageFile?.imgUrl)!)
        
        (item as! ScreenShotCollectionViewItem).setHighlight(selected: true)
        
    }
    
    // 4
    
    internal func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        
        guard let indexPath = indexPaths.first else {
            return
        }
        guard let item = collectionView.item(at: indexPath as IndexPath) else {
            return
        }
        (item as! ScreenShotCollectionViewItem).setHighlight(selected: false)
        
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
        
        
        (item as! ScreenShotCollectionViewItem).setHighlight(selected: false)
    }
}
