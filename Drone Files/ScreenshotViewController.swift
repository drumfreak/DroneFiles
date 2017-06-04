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

    let geocoder = CLGeocoder()
    var latitude: Double?, originalLatitude: Double?
    var longitude: Double?, originalLongitude: Double?
    var fileFun: FileFunctions!
    var timestamp:NSDate?
    var coordinate:CLLocationCoordinate2D?
    
    @IBOutlet var saveDirectoryName: String!
    @IBOutlet var screenshotPath: String!
    @IBOutlet var screenshotPathFull: String!
    @IBOutlet var screenshotPathFullURL: String!
    @IBOutlet var screenshotName: String!
    @IBOutlet var screenshotNameFull: String!
    @IBOutlet var screenshotNameFullURL: String!
    
    var timeOffset = 0.00
    var modificationDate = Date()
    
    var audioPlayer: AVAudioPlayer?
    var videoAsset: AVAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appDelegate.screenshotViewController = self
    }
    
    func getLocationData(asset: AVAsset) -> String {
        var locationData = ""
        for metaDataItems in asset.commonMetadata {
            // print("Common Key: \(String(describing: metaDataItems.commonKey))")
            // print("Value: \(metaDataItems.value)")
            
            if metaDataItems.commonKey == "location" {
                locationData = (metaDataItems.value as! NSString) as String
                print("Location Data: \(locationData)")
            } else {
                
            }
        }
        return locationData
    }
    
    
    
    func takeScreenshot(asset: AVAsset, currentTime: CMTime, preview: Bool, modificationDate: Date) {
        self.appDelegate.appSettings.blockScreenShotTabSwitch = true
        let maxTime = asset.duration
        
        if(currentTime < kCMTimeZero || currentTime > maxTime) {
            return
        }
        self.videoAsset = asset
        
        self.longitude = 0.00
        self.latitude = 0.00
        let location = self.getLocationData(asset: asset)
        
        if(self.appSettings.screenshotSound) {
            self.playShutterSound()
        }
        
        self.modificationDate = modificationDate
        
        if(self.appSettings.screenshotTypeJPG && self.appSettings.screenshotPreserveVideoLocation) {
            
            if let range = location.range(of: "-") {
                
                let latFull = location[location.startIndex..<range.lowerBound]
                
                let longFull = location[range.lowerBound..<location.endIndex]
                
                let lat = latFull.replacingOccurrences(of: "+", with: "")
                
                var long = longFull.replacingOccurrences(of: "+", with: "")
                
                var longArray = long.components(separatedBy: ".")
                
                longArray.removeLast()
                
                long = longArray.joined(separator: ".")
                
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                
                let finalLong = numberFormatter.number(from: long)
                let finalLat = numberFormatter.number(from: lat)
                
                print("Long: \(finalLong as Any)")
                print("Lat: \(finalLat as Any)")
                
                self.longitude = finalLong?.doubleValue
                
                self.latitude = finalLat?.doubleValue
                
            }
            
        }
        
        // print("Taking Screenshot")
        
        // print("Screen shot at: \(String(describing: currentTime))")
        
        do {
            
            if(currentTime >= kCMTimeZero && currentTime < maxTime) {
                let url =  self.generateThumbnail(asset: asset, fromTime: currentTime)
                
                self.appDelegate.appSettings.mediaBinUrls.append(url!)
                self.appDelegate.saveProject()
                
                if(self.appSettings.screenshotPreview) {
                    
                    DispatchQueue.main.async {
                        
                       self.appDelegate.mediaBinCollectionView.reloadContents()
                        self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: url!)
                        
                        self.appDelegate.mediaBinCollectionView.selectItemOne()
                        
                    }
                    
                }
                
                self.appDelegate.appSettings.blockScreenShotTabSwitch = false
                
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
    func generateThumbnail(asset: AVAsset, fromTime:CMTime) -> URL! {
        
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero;
        assetImgGenerate.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture
        
        
        var img: CGImage?
        
        do {
            img = try assetImgGenerate.copyCGImage(at:fromTime, actualTime: nil)
            // print("Screen shot captured yeah...")
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
        }
        
        if img != nil {
            if(saveImage(image: img!)) {
                let url = URL(string: self.screenshotNameFullURL)
                return url
            } else {
                return nil
            }
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
                let files = try FileManager.default.contentsOfDirectory(at: URL(string: self.appSettings.screenShotFolder)!, includingPropertiesForKeys: nil, options: [])
                
                incrementer = String(format: "%04d", files.count)
            } catch let error as NSError {
                print(error.localizedDescription + "ok")
            }
        }
        
        return incrementer
    }
    
    func getScreenshotPath() -> URL! {
        
        var fileExtension = "jpg"
        
        if(self.appSettings.screenshotTypePNG) {
            fileExtension = "png"
        }
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "HHmm.ss"
        
        let now = dateformatter.string(from: self.modificationDate)
        
        self.screenshotPathFull = self.appSettings.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
        
        self.screenshotPath = self.screenshotPathFull.replacingOccurrences(of: "file://", with: "")
        
        let increment = getScreenShotIncrement(_folder: self.appSettings.screenShotFolder)
        
        if(self.appSettings.screenshotPreserveVideoName) {
            
            let assetUrl = self.appDelegate.videoControlsController.currentVideoURL
            
            let filename = assetUrl?.deletingPathExtension()
            
            let tmpName = filename!.lastPathComponent
            
            var screenShotName = tmpName + " - " + increment
            
            screenShotName +=  " - " + now + "." + fileExtension
            
            self.screenshotName = screenShotName
            
            
        } else {
            self.screenshotName = self.appSettings.saveDirectoryName + " - " + increment + " - "  + now + "." + fileExtension
        }
        
        self.screenshotNameFull = self.screenshotPathFull + "/" + self.screenshotName
        
        self.screenshotNameFullURL = self.screenshotNameFull.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: self.screenshotNameFull.replacingOccurrences(of: "file://", with: "")) {
            // print("Fuck that file screenshot exists..")
            let incrementer = "00000"
            self.screenshotName = self.appSettings.saveDirectoryName +  " - " + increment + " - " + now + " - " + incrementer  + "." + fileExtension
            
            self.screenshotNameFull = self.screenshotPathFull + "/" + self.screenshotName
            self.screenshotNameFullURL = self.screenshotNameFull.replacingOccurrences(of: " ", with: "%20")
            
        } else {
            // print("That screenshot does not exist..")
        }
        
        return URL(string: self.screenshotNameFullURL)!
        
        // return self.screenshotPath
    }
    
    func getScreenshotPathsForBurst(fileExtension: String, videoURL: URL! ) -> [URL]! {
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "HHmm.ss"
    
        modificationDate = fileFun.getScreenShotDate(originalFile: videoURL, offset: 0)
        
        let now = dateformatter.string(from: modificationDate)
        
        self.screenshotPathFull = self.appSettings.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
        
        self.screenshotPath = self.screenshotPathFull.replacingOccurrences(of: "file://", with: "")
        
        let increment = getScreenShotIncrement(_folder: self.appSettings.screenShotFolder)
        
        if(self.appSettings.screenshotPreserveVideoName) {
            
            let assetUrl = self.appDelegate.videoControlsController.currentVideoURL
            
            let filename = assetUrl?.deletingPathExtension()
            
            let tmpName = filename!.lastPathComponent
            
            var screenShotName = tmpName + " - " + increment
            
            screenShotName +=  " - " + now + "." + fileExtension
            
            self.screenshotName = screenShotName
            
        } else {
            
            self.screenshotName = self.appSettings.saveDirectoryName + " - " + increment + " - "  + now + "." + fileExtension
        
        }
        
        self.screenshotNameFull = self.screenshotPathFull + "/" + self.screenshotName
        
        self.screenshotNameFullURL = self.screenshotNameFull.replacingOccurrences(of: " ", with: "%20")
        
        if FileManager.default.fileExists(atPath: self.screenshotNameFull.replacingOccurrences(of: "file://", with: "")) {
            // print("Fuck that file screenshot exists..")
            let incrementer = "00000"
            self.screenshotName = self.appSettings.saveDirectoryName +  " - " + increment + " - " + now + " - " + incrementer  + "." + fileExtension
            
            self.screenshotNameFull = self.screenshotPathFull + "/" + self.screenshotName
            self.screenshotNameFullURL = self.screenshotNameFull.replacingOccurrences(of: " ", with: "%20")
            
        } else {
            // print("That screenshot does not exist..")
        }
        
        // return URL(string: self.screenshotNameFullURL)!
        return []
        // return self.screenshotPath
    }
    
    func imageWrite(data: Data, to url: URL!, options: Data.WritingOptions = .atomic) -> Bool {
        
        do {
            try data.write(to: url, options: options )
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    
    
    func saveImage(image: CGImage) -> Bool {
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
            
            self.screenshotPathFull = self.appSettings.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
            self.screenshotPath = self.screenshotPathFull.replacingOccurrences(of: "file://", with: "")
            
            do {
                try FileManager.default.createDirectory(atPath: self.screenshotPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ as NSError {
                print("Error while creating a folder.")
            }
            
            let _ =  self.getScreenshotPath()
            
            let nsImage = NSImage(cgImage: cgImage!, size: (ciImage?.extent.size)!)
            
            
            // let data = self.pngData(img: nsImage)
            
            var data = Data()
            
            if(self.appSettings.screenshotTypeJPG) {
                data = nsImage.imageJPGRepresentation()! as Data
            } else {
                data = nsImage.imagePNGRepresentation()! as Data
            }
            
            let surl = URL(string: (self.screenshotNameFullURL)!)
            
            if self.imageWrite(data: data as Data , to: surl, options: .withoutOverwriting) {
                
                self.exifWriteData(path: self.screenshotNameFullURL)
                print("Screenshot File saved")
                
                if(self.appSettings.screenshotPreserveVideoDate) {
                    self.setFileDate(originalFile: self.screenshotNameFullURL.replacingOccurrences(of: "file://", with: ""))
                }
                
                // self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
            
                return true
            } else {
                print("Screenshot File saved FAILED")
                
                return false
            }
        }
    }
    
    
    func exifWriteData(path: String) {
        var latArg = "-GPSLatitude="
        var latRefArg = "-GPSLatitudeRef="
        if var lat = latitude {
            if lat < 0 {
                latRefArg += "S"
                lat = -lat
            } else {
                latRefArg += "N"
            }
            latArg += "\(lat)"
        }
        
        var lonArg = "-GPSLongitude="
        var lonRefArg = "-GPSLongitudeRef="
        
        if var lon = longitude {
            if lon < 0 {
                lonRefArg += "W"
                lon = -lon
            } else {
                lonRefArg += "E"
            }
            lonArg += "\(lon)"
        }
        
        let exiftool = Process()
        exiftool.standardOutput = FileHandle.nullDevice
        exiftool.standardError = FileHandle.nullDevice
        exiftool.launchPath = "/usr/local/bin/exiftool"
        exiftool.arguments = ["-q", "-m",
                              "-DateTimeOriginal>FileModifyDate", latArg, latRefArg,
                              lonArg, lonRefArg, getPathFromURL(path: path)]
        
        exiftool.arguments?.insert("-overwrite_original", at: 2)
        exiftool.launch()
        exiftool.waitUntilExit()
        
    }
    
    
    func geocode(completionHandler:@escaping (CLPlacemark?) -> Void) {
        guard let coordinate = self.coordinate else { return }
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            print("geo code \(String(describing: error))")
            completionHandler(placemarks?.first)
        }
    }
    
    
    func getPathFromURL(path: String) -> String {
        var path = path.replacingOccurrences(of: "file://", with: "")
        path = path.replacingOccurrences(of: "%20" , with: " ")
        return path
    }
    
    
    func playShutterSound() {
        
        let url = Bundle.main.url(forResource: "Shutter", withExtension: "aif")!
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            guard let audioPlayer = audioPlayer else { return }
            
            self.audioPlayer = audioPlayer
            self.audioPlayer?.prepareToPlay()
            // self.audioPlayer?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }

        self.audioPlayer?.play()
    }
    
}


extension NSImage {
    func imagePNGRepresentation() -> NSData? {
        if let imageTiffData = self.tiffRepresentation, let imageRep = NSBitmapImageRep(data: imageTiffData) {
            // let imageProps = [NSImageCompressionFactor: 0.9] // Tiff/Jpeg
            // let imageProps = [NSImageInterlaced: NSNumber(value: true)] // PNG
            let imageProps: [String: Any] = [:]
            let imageData = imageRep.representation(using: NSBitmapImageFileType.PNG, properties: imageProps) as NSData?
            return imageData
        }
        return nil
    }
}

extension NSImage {
    func imageJPGRepresentation() -> NSData? {
        if let imageTiffData = self.tiffRepresentation, let imageRep = NSBitmapImageRep(data: imageTiffData) {
            let imageProps = [NSImageCompressionFactor: 1.0] // Tiff/Jpeg
            // let imageProps = [NSImageInterlaced: NSNumber(value: true)] // PNG
            // let imageProps: [String: Any] = [:]
            let imageData = imageRep.representation(using: NSBitmapImageFileType.JPEG, properties: imageProps) as NSData?
            return imageData
        }
        return nil
    }
}
