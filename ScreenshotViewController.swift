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
    @IBOutlet weak var imageEditorViewController: ImageEditorViewController!
    
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
        print("Loaded Screen Shot Editor")
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
    
    func loadImage(url: URL) {
        // imageView.show
        
        
        do {
            let data = try Data.init(contentsOf: url)
            
            let image: NSImage! = NSImage.init(data: data)
            let image2: CIImage! = CIImage.init(data: data)
            let image3 = convertCIImageToCGImage(inputImage: image2)
            
            // self.imageView.setImage(image3, imageProperties: image3 as! [AnyHashable : Any])
            
            //  self.imageView.setImage(
        } catch {
            print(error.localizedDescription)
        }
        
        
        
        
        //print(cgimage)
        
        // let c = Image
        
        // self.imageView.setImage(CGImage!, imageProperties: <#T##[AnyHashable : Any]!#>)
        
        self.imageView.setImageWith(url as URL!)
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        if context != nil {
            return context.createCGImage(inputImage, from: inputImage.extent)
        }
        return nil
    }
    
    func takeScreenshot(asset: AVAsset, currentTime: CMTime) {
        print("Taking Screenshot");
        print("Screen shot at: \(String(describing: currentTime))")
        do {
            let imageURL: String! =  self.generateThumnail(asset: asset, fromTime: currentTime)!
            
            Thread.sleep(forTimeInterval: 1)
            
            self.imageView.setImageWith(URL(string: imageURL!)!)
        }
        
        // imageView.setImageWith(imageURL)
    }
    
    
    // Screen shot stuff
    func generateThumnail(asset: AVAsset, fromTime:CMTime) -> String? {
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
    
    func saveImage(image: CGImage) -> String! {
        let context = CIContext()
        // let retUrl: URL!
        // let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        
        do {
            // guard
            let filter = CIFilter(name: "CISepiaTone")
            let ciImage = convertCGImageToCIImage(inputImage: image)
            
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(0.5, forKey: kCIInputIntensityKey)
            
            let result = filter?.outputImage
            let cgImage = context.createCGImage(result!, from: (result?.extent)!)
            
            
            let dateformatter = DateFormatter()
            
            dateformatter.dateFormat = "MM-dd-YYYY-hhmmss"
            
            let now = dateformatter.string(from: NSDate() as Date)
            
            let stringURL: String = "file:///Volumes/NO%20NAME/DCIM/100MEDIA/" + now + "my-image.png"
            let destinationURL: URL!
            destinationURL = URL(string: stringURL)
            
            print("Destination \(String(describing: destinationURL!))")
            
            // let destinationURL = desktopURL.appendingPathComponent("my-image.png")
            let nsImage = NSImage(cgImage: cgImage!, size: (ciImage?.extent.size)!)
            if nsImage.pngWrite(to: destinationURL, options: .withoutOverwriting) {
                print("File saved")
            }
            
            return stringURL
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
