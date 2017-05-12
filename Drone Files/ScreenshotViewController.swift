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
import CoreLocation


class ScreenshotViewController: NSViewController {
    @IBOutlet var imageView: IKImageView!
    @IBOutlet var imageName: NSTextField!
    @IBOutlet var imageEditorView: NSView!
    
    let geocoder = CLGeocoder()

    var timestamp:NSDate?
    var coordinate:CLLocationCoordinate2D?
    var altitude: Double?

    @IBOutlet weak var newFileNamePath: NSTextField!
    @IBOutlet var saveDirectoryName: String!

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
    
    var audioPlayer: AVAudioPlayer?

    
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
            
            
            
            let imageSource = CGImageSourceCreateWithURL(url! as CFURL, nil)
            let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil) as! [String:Any]
            
            print(imageProperties)
            
            // let exifDict = imageProperties["{Exif}"] as! [String:Any]
            
            
            
            // let dateTimeOriginal = exifDict["DateTimeOriginal"] as! String
            // print ("DateTimeOriginal: \(dateTimeOriginal)")
            


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
            let attributes = [
                FileAttributeKey.creationDate: newDate,
                FileAttributeKey.modificationDate: newDate
            ]
            
            do {
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
        var incrementer = "0000"
        if FileManager.default.fileExists(atPath: self.screenshotPath) {
            do {
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.appDelegate.fileBrowserViewController.screenShotFolder)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%04d", files.count)
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func getScreenshotPath(_screenshotPath : String) -> String {
        self.screenshotPathFull = self.appDelegate.fileBrowserViewController.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
        
        self.screenshotPath = self.screenshotPathFull.replacingOccurrences(of: "file://", with: "")
        
        let increment = getScreenShotIncrement(_folder: self.appDelegate.fileBrowserViewController.screenShotFolder)
    
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "HHmm.ss"
        
        let now = dateformatter.string(from: self.modificationDate)
        
        self.screenshotName = self.appDelegate.fileBrowserViewController.saveDirectoryName + " - " + increment + " - " + now + ".png"
        
        self.screenshotNameFull = self.screenshotPathFull + "/" + self.screenshotName
        
        self.screenshotNameFullURL = self.screenshotNameFull.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: self.screenshotNameFull.replacingOccurrences(of: "file://", with: "")) {
            print("Fuck that file screenshot exists..")
            let incrementer = "00000"
            self.screenshotName = self.appDelegate.fileBrowserViewController.saveDirectoryName +  " - " + increment + " - " + now + " - " + incrementer + ".png"
            
            self.screenshotNameFull = self.screenshotPathFull + "/" + self.screenshotName
            self.screenshotNameFullURL = self.screenshotNameFull.replacingOccurrences(of: " ", with: "%20")
            
        } else {
            // print("That screenshot does not exist..")
        }
        
        return self.screenshotPath
    }

    
    
    func pngData(img: NSImage, metaData: NSDictionary) -> Data{
        
        // var m = NSImageEXIFData
        let tiffRepresentation = img.tiffRepresentation
        let bitmapImage = NSBitmapImageRep(data: tiffRepresentation!)
        let bm = bitmapImage?.representation(using: .PNG, properties: metaData as! [String : Any])
        
        return bm!
    }
    
    
    func pngWrite(data: Data, to url: URL, options: Data.WritingOptions = .atomic) -> Bool {
        
        do {
            try data.write(to: url, options: options )
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    
    
    func saveImage(image: CGImage) -> String! {
        let context = CIContext()
        
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
            
            self.screenshotPathFull = self.appDelegate.fileBrowserViewController.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
            self.screenshotPath = self.screenshotPathFull.replacingOccurrences(of: "file://", with: "")
            
            do {
                try FileManager.default.createDirectory(atPath: self.screenshotPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ as NSError {
                print("Error while creating a folder.")
            }
        
            
            
            let stringURL =  self.getScreenshotPath(_screenshotPath: " ")

            
            let nsImage = NSImage(cgImage: cgImage!, size: (ciImage?.extent.size)!)
            
            
            let data = self.pngData(img: nsImage, metaData: self.writeMetaData())
            
            if self.pngWrite(data: data , to: URL(string: self.screenshotNameFullURL)!, options: .withoutOverwriting) {
                
                
                
                
                print("File saved")
            }
            
            if(self.screenshotItemPreserveFileDates) {
                self.setFileDate(originalFile: self.screenshotNameFull.replacingOccurrences(of: "file://", with: ""))
            }
            self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
            
            
            return stringURL
        }
    }
    
    
    func geocode(completionHandler:@escaping (CLPlacemark?) -> Void) {
        guard let coordinate = self.coordinate else { return }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            print("geo code \(String(describing: error))")
            completionHandler(placemarks?.first)
        }
    }
    
    func writeMetaData() -> NSMutableDictionary {
        
    
        let longitude = +27.821788-82
        let latitude = 831942+3.100
        
        let properties:[String:AnyObject] = [
            kCGImagePropertyGPSSpeed as String : 0 as AnyObject,
            kCGImagePropertyGPSSpeedRef as String : "K" as AnyObject,
            kCGImagePropertyGPSAltitudeRef as String : 0 as AnyObject,
            kCGImagePropertyGPSImgDirection as String : 0.0 as AnyObject,
            kCGImagePropertyGPSImgDirectionRef as String : "T" as AnyObject,
            kCGImagePropertyGPSLatitude as String : Double(latitude) as AnyObject,
            kCGImagePropertyGPSLatitudeRef as String : latitude > 0 ? "N" as AnyObject : "S" as AnyObject,
            
            kCGImagePropertyGPSLongitude as String : Double(longitude) as AnyObject,
            kCGImagePropertyGPSLongitudeRef as String : longitude > 0 ? "E" as AnyObject : "W" as AnyObject,
            ]
        
       //  print("properties: \(properties)")
        return properties as! NSMutableDictionary
    }
    
    
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
