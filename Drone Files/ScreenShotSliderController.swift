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

    let mediaBinLoader = MediaBinLoader()

    
    func loadDataForNewFolderWithUrl(_ folderURL: URL) {
        mediaBinLoader.loadDataForFolderWithUrl(folderURL)
        collectionView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.screenShotSliderController = self
        self.reloadContents()
    }
    
    
    func reloadContents() {
        
        // mediaBinLoader.loadDataForFolderWithUrl(initialFolderUrl)
        
        mediaBinLoader.loadDataFromUrls(self.appDelegate.appSettings.mediaBinUrls as! NSMutableArray)
        
        configureCollectionView()
        
        
    }

    private func configureCollectionView() {
        // 1
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 140.0)
        flowLayout.sectionInset = EdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
        // 2
        view.wantsLayer = true
        // 3
        collectionView.layer?.backgroundColor = NSColor.black.cgColor
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
        return item
    }
    
}
