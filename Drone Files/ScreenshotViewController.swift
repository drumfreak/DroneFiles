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

class ScreenshotViewController: NSViewController {
    
    @IBOutlet weak var videoPlayerViewController: VideoPlayerViewController!
    @IBOutlet weak var editorTabViewController: EditorTabViewController!
    //@IBOutlet weak var imageEditorViewController: ImageEditorViewController!
    @IBOutlet weak var fileBrowserViewController: FileBrowserViewController!
    
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
    
    @IBOutlet var screenshotPath: String!
    @IBOutlet var screenshotPathFull: String!
    @IBOutlet var screenshotPathFullURL: String!
    @IBOutlet var screenshotName: String!
    @IBOutlet var screenshotNameFull: String!
    @IBOutlet var screenshotNameFullURL: String!
    var timeOffset = 0.00
    var screenshotItemPreserveFileDates = true
    var modificationDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // print("Loaded Screen Shot Editor")
        imageView.autoresizes = true
        imageView.supportsDragAndDrop = true
        imageView.editable = true
        
        let rgb = NSColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        imageView.backgroundColor = rgb
    }
    
    func loadImage(_url: URL) {
        self.imageView.setImageWith(_url)
    }
    
    func takeScreenshot(asset: AVAsset, currentTime: CMTime, preview: Bool, modificationDate: Date) {
        
        self.modificationDate = modificationDate
        
        print("Taking Screenshot")
        self.playShutterSound()
        
        print("Screen shot at: \(String(describing: currentTime))")
        do {
            let _: String! =  self.generateThumbnail(asset: asset, fromTime: currentTime)!
            
            let url = URL(string: self.screenshotNameFullURL)
            
            
            //self.editorTabViewController.selectedTabViewItemIndex = 1
            if(preview == true) {
               // print("SCREEN SHOT PREVIEWING : \(String(describing: url))")
                self.imageView.setImageWith(url)
            }
        }
        
    }
    
    
    func setFileDate(originalFile: String) {
        
        var original = originalFile.replacingOccurrences(of: "file://", with: "");
        original = original.replacingOccurrences(of: "%20", with: " ");

        do {
            
            let newDate = self.modificationDate
            // let newDate = Calendar.current.date(byAdding: .second, value: Int(self.trimOffset), to: modificationDate)
            
            // print("Modification date: ", self.modificationDate)
            
            let attributes = [
                FileAttributeKey.creationDate: newDate,
                FileAttributeKey.modificationDate: newDate
            ]
            
            do {
                // THIS IS BROKEN!!
                //print("ORIGINAL PATH : \(original)")
                //print("ATTRIBUTES: \(attributes)")
                
                try FileManager.default.setAttributes(attributes, ofItemAtPath: original)
            } catch {
                print(error)
            }
        }
    }
    
    // Screen shot stuff
    func generateThumbnail(asset: AVAsset, fromTime:CMTime) -> String? {
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero;
        var img: CGImage?
        do {
            img = try assetImgGenerate.copyCGImage(at:fromTime, actualTime: nil)
            print("Screen shot captured yeah...")
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
        }
        
        if img != nil {
            let returnUrl = saveImage(image: img!)
            
            //  print("IMAGE URL \(returnUrl)")
            
            return returnUrl
        } else {
            return nil
        }
    }
    
    func convertCGImageToCIImage(inputImage: CGImage) -> CIImage! {
        let ciImage = CIImage(cgImage: inputImage)
        return ciImage
    }
    
    
    // Screen shot files
    func getScreenShotIncrement(_folder: String) -> String {
        var incrementer = "00"
        if FileManager.default.fileExists(atPath: self.screenshotPath) {
            // print("url is a folder url")
            // lets get the folder files
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.fileBrowserViewController.screenShotFolder)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%02d", files.count)
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func getScreenshotPath(_screenshotPath : String) -> String {
        self.screenshotPathFull = self.fileBrowserViewController.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
        self.screenshotPath = self.screenshotPathFull.replacingOccurrences(of: "file://", with: "")
       //  self.screenshotPathFullURL = URL(string: self.mainViewController.screenShotFolder)
        
        let increment = getScreenShotIncrement(_folder: self.fileBrowserViewController.screenShotFolder)
        
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "MM-dd-YYYY-hhmmss"
        
        let now = dateformatter.string(from: NSDate() as Date)
        
        self.screenshotName = self.fileBrowserViewController.saveDirectoryName + " - " + increment + " - " + now + ".png"
        self.screenshotNameFull = self.screenshotPathFull + "/" + self.screenshotName
        
        self.screenshotNameFullURL = self.screenshotNameFull.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: self.screenshotNameFull.replacingOccurrences(of: "file://", with: "")) {
            print("Fuck that file screenshot exists..")
            let incrementer = "00000"
            self.screenshotName = self.fileBrowserViewController.saveDirectoryName +  " - " + increment + " - " + now + " - " + incrementer + ".MOV"
            
            self.screenshotNameFull = self.screenshotPathFull + "/" + self.screenshotName
            self.screenshotNameFullURL = self.screenshotNameFull.replacingOccurrences(of: " ", with: "%20")
            
        } else {
            // print("That screenshot does not exist..")
        }
        
        return self.screenshotPath
    }

    
    
    func saveImage(image: CGImage) -> String! {
        let context = CIContext()
        // let retUrl: URL!
        // let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        
        do {
            // guard
            let filter = CIFilter(name: "CISepiaTone")
            let ciImage = convertCGImageToCIImage(inputImage: image)
            
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(0.0, forKey: kCIInputIntensityKey)
            
            let result = filter?.outputImage
            let cgImage = context.createCGImage(result!, from: (result?.extent)!)
            
            
            let dateformatter = DateFormatter()
            
            dateformatter.dateFormat = " HH-mm-ss"
            
            self.screenshotPathFull = self.fileBrowserViewController.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
            self.screenshotPath = self.screenshotPathFull.replacingOccurrences(of: "file://", with: "")
            
            do {
                try FileManager.default.createDirectory(atPath: self.screenshotPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ as NSError {
                print("Error while creating a folder.")
            }

        
            let stringURL =  self.getScreenshotPath(_screenshotPath: " ")

            // let destinationURL = desktopURL.appendingPathComponent("my-image.png")
            let nsImage = NSImage(cgImage: cgImage!, size: (ciImage?.extent.size)!)
            if nsImage.pngWrite(to: URL(string: self.screenshotNameFullURL)!, options: .withoutOverwriting) {
                print("File saved")
            }
            
            
            if(self.screenshotItemPreserveFileDates) {
                self.setFileDate(originalFile: self.screenshotNameFull.replacingOccurrences(of: "file://", with: ""))
            }
            self.fileBrowserViewController.reloadFileList()
            
            return stringURL
        }
    }
    
    
    var audioPlayer: AVAudioPlayer?
    
    func playShutterSound() {
        let url = Bundle.main.url(forResource: "Shutter", withExtension: "aif")!
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let audioPlayer = audioPlayer else { return }
            
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension NSImage {
    var pngData: Data? {
        guard let tiffRepresentation = tiffRepresentation, let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .PNG, properties: [:])
    }
    func pngWrite(to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        do {
            try pngData?.write(to: url, options: options)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
}
