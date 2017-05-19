//
//  ScreenShotSliderController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa


class ScreenShotSliderController: NSViewController {
    // View controllers
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var countLabel: NSButton!
    
    @IBOutlet weak var scrollView: ThemeScrollView!

    
    var viewConfigured = false
    
    let mediaBinLoader = MediaBinLoader()
    
    
    func loadDataForNewFolderWithUrl(_ folderURL: URL) {
        mediaBinLoader.loadDataForFolderWithUrl(folderURL)
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countLabel.stringValue = "0"

        self.appDelegate.screenShotSliderController = self
        self.reloadContents()
        self.collectionView.resignFirstResponder()
        self.resignFirstResponder()

        self.selectItemOne()

        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appBackgroundColor.cgColor
        
        
    }
    
    
    func selectItemOne() {
       //  let indexPath = Set()
       //  indexPath.ini
        
        let path = NSIndexPath.init(forItem: 0, inSection: 0)
        
        self.collectionView.selectItems(at: Set([path]) as Set<IndexPath>, scrollPosition: NSCollectionViewScrollPosition.top)
    }
    
    func reloadContents() {
        
        // mediaBinLoader.loadDataForFolderWithUrl(initialFolderUrl)
        
        mediaBinLoader.loadDataFromUrls(self.appDelegate.appSettings.mediaBinUrls as! NSMutableArray)
        
        configureCollectionView()
        collectionView.reloadData()
        
        self.countLabel.title = String(format: "%1d", self.appSettings.mediaBinUrls.count)
        
        self.collectionView.resignFirstResponder()
        self.resignFirstResponder()
    }
    
    
    
    
    @IBAction func clearMediaBin (_ sender : AnyObject) {
        self.appDelegate.appSettings.mediaBinUrls.removeAll(keepingCapacity: false)
        
        self.reloadContents()
    }
 
 
    @IBAction func openSecondDisplay (_ sender : AnyObject) {
       /*
        self.appDelegate.externalScreens = NSScreen.externalScreens()
        
        let screenRect = self.appDelegate.externalScreens[0].frame
        
        

         let secondWindowController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "secondWindowController") as? SecondWindowController
        
        secondWindowController?.window = secondwindow
        
        secondwindow.makeKeyAndOrderFront(self)

        
        secondWindowController?.showWindow(self)
        */
    
    }
    
    private func configureCollectionView() {
        
        if(!self.viewConfigured) {
            
            // 1
            let flowLayout = NSCollectionViewFlowLayout()
            flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
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
    
}


extension ScreenShotSliderController : NSCollectionViewDataSource {
    
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

extension ScreenShotSliderController : NSCollectionViewDelegate {
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
