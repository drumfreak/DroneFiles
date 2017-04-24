//
//  ImageEditorViewController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/21/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz

class ImageEditorViewController: NSViewController {
    
    @IBOutlet weak var screenshotViewController: ScreenshotViewController!
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var editorTabViewController: EditorTabViewController!
    @IBOutlet weak var mainViewController: FileBrowserViewController!
    
    
    @IBOutlet var imageView: IKImageView!
    @IBOutlet var imageName: NSTextField!
    @IBOutlet var imageEditorView: NSView!
    
    @IBOutlet weak var dateField: NSTextField!
    @IBOutlet weak var flightName: NSTextField!
    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet var saveDirectoryName: String!
    @IBOutlet var flightNameVar: String!
    @IBOutlet var dateNameVar: String!
    @IBOutlet var folderURL: String!
    @IBOutlet weak var folderURLDisplay: NSTextField!
    var nowPlayingURL: URL!
    @IBOutlet weak var nowPlayingFile: NSTextField!
    var nowPlayingURLString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Loaded Image Editor")
        imageView.autoresizes = true
        imageView.supportsDragAndDrop = true
        imageView.editable = true
        
        let rgb = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        
//        let red = 0.5;
//        let green = 0.2;
//        let blue = 0.4;
//        let alpha = 0.8;
       
       //  let rgb = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
        
        imageView.backgroundColor = rgb
    }
    
    func loadImage(_url: URL) {
        // imageView.show
        imageView.setImageWith(_url)
    }
}
