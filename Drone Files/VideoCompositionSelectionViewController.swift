//
//  VideoCompositionSelectionViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 6/14/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa


class VideoCompositionSelectionViewController: NSViewController {
    
    @IBOutlet var removeCompositionButton: NSButton!
    @IBOutlet var exportCompositionButton: NSButton!
    @IBOutlet var newCompositionButton: NSButton!
    @IBOutlet var compositionSelectMenu: NSPopUpButton!
    var managedObjectContext: NSManagedObjectContext!
    var videoManager = VideoFileManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.videoCompositionSelectionViewController = self
        self.managedObjectContext = self.appDelegate.persistentContainer.viewContext
        self.getCompositions()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.appDelegate.videoCompositionSelectionViewController = self
        self.managedObjectContext = self.appDelegate.persistentContainer.viewContext
        self.getCompositions()
    }
    
    
    func getCompositions() {
        
        let comps = self.videoManager.getAllCompositionsForVideo(video: self.appDelegate.videoDetailsViewController.videoFile)
        
        var compositionItems = [String]()
        
        var i = 1
        comps.forEach({ comp in
            compositionItems.append("\(i)")
            i += 1
        })
        
        self.compositionSelectMenu.addItems(withTitles: compositionItems)
        
        
        // compositionSelectMenu(withTitles: self.appSettings.videoSizeSelectMenuOptions)

    }
    
    @IBAction func exportComposition(sender: Any) {
        self.videoManager.exportComposition(composition: self.appDelegate.videoDetailsViewController.composition)
        
        
    }
}

