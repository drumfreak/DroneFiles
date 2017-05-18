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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//
//
//extension ScreenShotSliderController : NSCollectionViewDataSource {
//    
//    // 1
//    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
//        return imageDirectoryLoader.numberOfSections
//    }
//    
//    // 2
//    func collectionView(collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
//        return imageDirectoryLoader.numberOfItemsInSection(section)
//    }
//    
//    // 3
//    func collectionView(collectionView: NSCollectionView, itemForRepresentedObjectAtIndexPath indexPath: NSIndexPath) -> NSCollectionViewItem {
//        
//        // 4
//        let item = collectionView.makeItemWithIdentifier("CollectionViewItem", forIndexPath: indexPath)
//        guard let collectionViewItem = item as? CollectionViewItem else {return item}
//        
//        // 5
//        let imageFile = imageDirectoryLoader.imageFileForIndexPath(indexPath)
//        collectionViewItem.imageFile = imageFile
//        return item
//    }
//    
//}




class CollectionViewItem: NSCollectionViewItem {
    
    // 1
    var imageFile: NSImage? {
        didSet {
            guard isViewLoaded else { return }
//            if let imageFile = imageFile {
//               // imageView?.image = imageFile.thumbnail
//               // textField?.stringValue = imageFile.fileName
//            } else {
//                imageView?.image = nil
//                textField?.stringValue = ""
//            }
        }
    }
    
    // 2
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
}
