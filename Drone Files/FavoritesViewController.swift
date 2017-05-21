//
//  FavoritesViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/20/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa

class FavoritesViewController: NSViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.appDelegate.favoritesViewController = self
    }
    
    
    func addFavorite(url: URL) {
        
        
    }
    
    
    @IBAction func addToFavorites(_ sender : AnyObject) {
        
        
        
    }
    
}
