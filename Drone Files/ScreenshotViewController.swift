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
    var fileFun = FileFunctions()
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
                //print("Location Data: \(locationData)")
            } else {
                
            }
        }
        return locationData
    }
    
    
    
    func takeScreenshot(asset: AVAsset, assetURL: URL!,  currentTime: CMTime, preview: Bool, modificationDate: Date) {
        self.appDelegate.appSettings.blockScreenShotTabSwitch = true
        let maxTime = asset.duration
        
        if(currentTime < kCMTimeZero || currentTime > maxTime) {
            return
        }
        self.videoAsset = asset
        
        self.longitude = 0.00
        self.latitude = 0.00
        
        
        if(self.appSettings.screenshotSound) {
            self.playShutterSound()
        }
        
        self.modificationDate = modificationDate
        
        let location = self.getLocationFromVideo(asset: asset)

        if(location.count > 0) {
            if(self.appSettings.screenshotTypeJPG && self.appSettings.screenshotPreserveVideoLocation) {
                self.latitude = location[0]
                self.longitude = location[1]
            }
        }
        
        do {
            if(currentTime >= kCMTimeZero && currentTime < maxTime) {
                
                let outputURL = self.getScreenshotPath(startTime: currentTime, assetURL: assetURL)
            
                let url =  self.generateThumbnail(asset: asset, assetURL: assetURL, fromTime: currentTime, outputURL: outputURL!)
                
                self.appDelegate.appSettings.mediaBinUrls.append(url!)
                self.appDelegate.saveProject()
                if(self.appSettings.screenshotPreview) {
                    DispatchQueue.main.async {
                       self.appDelegate.mediaBinCollectionView.reloadContents()
                       // self.appDelegate.secondaryDisplayMediaViewController?.loadImage(imageUrl: url!)
                       // self.appDelegate.mediaBinCollectionView.selectItemOne()
                    }
                }
                self.appDelegate.appSettings.blockScreenShotTabSwitch = false
            }
        }
    }
    
    func getLocationFromVideo(asset: AVAsset) -> [Double] {
        
        let location = self.getLocationData(asset: asset)
        
        if(location.characters.count > 0) {
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
                
                //print("Long: \(finalLong as Any)")
                //print("Lat: \(finalLat as Any)")
                
                let longitude = finalLong?.doubleValue
                
                let latitude = finalLat?.doubleValue
                return [latitude!, longitude!]
            }
        }
    
        return []
        
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
    func generateThumbnail(asset: AVAsset, assetURL: URL!, fromTime:CMTime, outputURL: URL) -> URL! {
        
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
            if(saveImage(image: img!, outputURL: outputURL, videoURL: assetURL, currentTime: fromTime)){
                let url = outputURL
                return url
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    
    
    // Screen shot stuff
    func generateThumbnailsForBurst(asset: AVAsset,
                                    assetUrl: URL!,
                                    startTime: CMTime,
                                    times: [CMTime],
                                    urls: [URL],
                                    fileExtension: String,
                                    preserveLocation: Bool,
                                    preserveDate: Bool,
                                    fileDate: Date,
                                    _ progress: @escaping ((Progress, URL) -> Void),
                                    success: @escaping ((URL) -> Void),
                                    failure: @escaping ((NSError) -> Void)) {
        
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        var preserveLocation = preserveLocation
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = kCMTimeZero;
        assetImgGenerate.requestedTimeToleranceBefore = kCMTimeZero;
        assetImgGenerate.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture
        
        var ntimes = [NSValue]()
        times.forEach({ time in
            ntimes.append(NSValue(time: time))
        })
        
        let currentProgress = Progress(totalUnitCount: Int64(times.count))

        let location = self.getLocationFromVideo(asset: asset)
        
        if(location.count > 0) {
            if(preserveLocation) {
                if(fileExtension == "jpg" && preserveLocation) {
                    longitude = location[1]
                    latitude = location[0]
                }
            }
        } else {
            preserveLocation = false
        }
        
        // var img: CGImage?
        
        
        // print("@#$@#$@#$@#$@#$@# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  FRAMES TOTAL: \(times.count)")
        
        do {
            var i = 0
        
            assetImgGenerate.generateCGImagesAsynchronously(forTimes: ntimes,
                                                            completionHandler: { (imgTime, cgImage, imgCMTime, result, error) in
            
                if(error == nil) {
                    
                    // Modify the date offset here.

                    // var offset: CMTime
                    let thisFrametime = times[i]
                    let offsetFloat = CMTimeGetSeconds(thisFrametime)
                    
                    print("offsetFloat: \(offsetFloat)")
                    
                    let fileDate = self.fileFun.getFileModificationDate(originalFile:assetUrl, offset: offsetFloat)
                    
                    // print("NEW FILE DATE \(i) IS: \(fileDate)")
                    
                    if cgImage != nil {
                        if(!self.saveImageBurst(image: cgImage!,
                                                url: urls[i],
                                                fileExtension: fileExtension,
                                                preserveLocation: preserveLocation,
                                                location: location,
                                                preserveDate: preserveDate,
                                                fileDate: fileDate
                                                )) {
                            // images.append(urls[i])
                            // Remove the blank url.. it's defunct
                        }
                    } else {
                        // Remove the blank url.. it's defunct
                    }
                    
                } else {
                    print(error?.localizedDescription as Any)
                }

                i += 1
                                                                
                                                                
                                                                
                // print("@#$@#$@#$@#$@#$@# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  PROCESSED FRAME: \(Int64(i))")
                                                                
                currentProgress.completedUnitCount = Int64(i)
                progress(currentProgress, urls[(i - 1)])
                
                if(i == times.count) {
                    success(urls[0])
                }
                
            })
            
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
    
    func getScreenshotPath(startTime: CMTime, assetURL: URL!) -> URL! {
        
        var fileExtension = "jpg"
        
        if(self.appSettings.screenshotTypePNG) {
            fileExtension = "png"
        }
        
        
        do {
            try FileManager.default.createDirectory(atPath: (URL(string: self.appDelegate.appSettings.screenShotFolder)?.path)!, withIntermediateDirectories: true, attributes: nil)
        } catch _ as NSError {
            print("Error while creating a folder.")
        }
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "HHmm.ss.SSSS"
        
        let offsetFloat = CMTimeGetSeconds(startTime)
        
        let fileDate = fileFun.getFileModificationDate(originalFile: assetURL, offset: offsetFloat)
        
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 7
        formatter.maximumIntegerDigits = 7
        
        // let oneFrame = CMTimeMakeWithSeconds(1.0 / 29.97, startTime!.timescale);

        let asset = AVAsset(url: assetURL)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)
        let fps = assetTrack[0].nominalFrameRate

        print("FPS is \(fps)")
        
        let currentFrame = floor(Double(Float(startTime.seconds) * fps))
        
        print("~~~~~~~~~~~~~~~    Could the frame be: \(currentFrame)")
        
        let nowString = formatter.string(from: NSNumber(value: currentFrame))
        
        let now = nowString! + " - \(dateformatter.string(from: fileDate))"
      
        self.screenshotPathFull = self.appSettings.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
        
        self.screenshotPath = self.screenshotPathFull.replacingOccurrences(of: "file://", with: "")
        
        let increment = getScreenShotIncrement(_folder: self.appSettings.screenShotFolder)
        
        let assetUrl = self.appDelegate.videoControlsController.currentVideoURL
        
        let filename = assetUrl?.deletingPathExtension()
        
        let tmpName = filename!.lastPathComponent
        
        if(self.appSettings.screenshotPreserveVideoName) {
            self.screenshotName =  "\(tmpName) - \(now) - \(increment).\(fileExtension)"
        } else {
            self.screenshotName = "\(self.appDelegate.appSettings.saveDirectoryName!) - \(now) - \(increment).\(fileExtension)"
        }
        
        self.screenshotNameFull = "\(self.screenshotPathFull!)/\(self.screenshotName!)"
        
        
        self.screenshotNameFullURL = self.screenshotNameFull!.replacingOccurrences(of: " ", with: "%20")
        
        
        let formatter2 = NumberFormatter()
        formatter2.minimumIntegerDigits = 4
        formatter2.maximumIntegerDigits = 4
        
    
        func fileExists(path: String) -> Bool {
            
            if(FileManager.default.fileExists(atPath: path.replacingOccurrences(of: "file://", with: ""))) {
                return true
                } else {
                return false
            }
        }
        var z = 0
        while(fileExists(path: self.screenshotNameFull!)) {
            print("File exists...looping for another round...\(z)")
            let incrementer = formatter2.string(from: NSNumber(value: z))
            
            if(self.appSettings.screenshotPreserveVideoName) {
                 self.screenshotName = "\(tmpName) - \(now) - \(increment) - \(incrementer!).\(fileExtension)"
                
            } else {
                self.screenshotName = "\(self.appSettings.saveDirectoryName!) - \(now) - \(increment) - \(incrementer!).\(fileExtension)"
            }
            self.screenshotNameFull = "\(self.screenshotPathFull!)/\(self.screenshotName!)"
            
            self.screenshotNameFullURL = self.screenshotNameFull!.replacingOccurrences(of: " ", with: "%20")
            
            z += 1
            
        }
        
        
        // print("fuckkkkkk \(self.screenshotNameFull)")
            
        return URL(string: self.screenshotNameFullURL!)!
        
        // return self.screenshotPath
    }
    
    func getScreenshotPathsForBurst(assetUrl: URL,
                                    startTime: CMTime,
                                    times: [CMTime],
                                    numFiles: Int,
                                    fileExtension: String,
                                    preserveVideoName: Bool,
                                    writeFile: Bool) -> [URL]! {
        
        // print("ASSET FUCKING URL: \(assetUrl)")
        
        
        do {
            try FileManager.default.createDirectory(atPath: (URL(string: self.appDelegate.appSettings.screenShotFolder)?.path)!, withIntermediateDirectories: true, attributes: nil)
        } catch _ as NSError {
            print("Error while creating a folder.")
        }

        var urls = [URL]()
        
        let dateformatter = DateFormatter()
        
        dateformatter.dateFormat = "HHmm.ss.SSSS"
       
        var screenshotName = ""
        
        var screenshotFullName = ""
        
        var screenshotNameFullURL = ""
        let screenshotPath = self.appSettings.screenShotFolder.replacingOccurrences(of: "%20", with: " ")
        
        
        
        let asset = AVAsset(url: assetUrl)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)
        let fps = assetTrack[0].nominalFrameRate
        
        print("FPS is \(fps)")
        
        

        var i = 0
        
        while(i < numFiles) {
       
            // let offset = CMTimeSubtract(times[i], startTime)
            
            let offsetFloat = CMTimeGetSeconds(times[i])
            
            let fileDate = fileFun.getFileModificationDate(originalFile: assetUrl, offset: offsetFloat)
            
            let formatter = NumberFormatter()
            formatter.minimumIntegerDigits = 7
            formatter.maximumIntegerDigits = 7
            
            
            let currentFrame = floor(Double(Float(times[i].seconds) * fps))
            
            print("~~~~~~~~~~~~~~~    Could the frame be: \(currentFrame)")
            
            let nowString = formatter.string(from: NSNumber(value: currentFrame))
            
            let now = nowString! + " - \(dateformatter.string(from: fileDate))"
            
            let increment = getScreenShotIncrement(_folder: self.appSettings.screenShotFolder)
            
            let filename = assetUrl.deletingPathExtension()
            
            let tmpName = filename.lastPathComponent
            
            if(preserveVideoName) {
                screenshotName = "\(tmpName) - \(now) - \(increment).\(fileExtension)"
            } else {
                screenshotName = "\(self.appSettings.saveDirectoryName!) - \(now) - \(increment).\(fileExtension)"
            }
            
            screenshotFullName = "\(screenshotPath)/\(screenshotName)"
            screenshotNameFullURL = screenshotFullName.replacingOccurrences(of: " ", with: "%20")
            
            let formatter2 = NumberFormatter()
            formatter2.minimumIntegerDigits = 4
            formatter2.maximumIntegerDigits = 4
            
            
            func fileExists(path: String) -> Bool {
                if(FileManager.default.fileExists(atPath: path.replacingOccurrences(of: "file://", with: ""))) {
                    return true
                } else {
                    return false
                }
            }
            var z = 0
            
            while(fileExists(path: screenshotFullName)) {
                // print("Fuck that file screenshot exists..")
                let incrementer = formatter2.string(from: NSNumber(value: z))

                if(preserveVideoName) {
                    screenshotName = "\(tmpName) - \(now) - \(increment) - \(incrementer!).\(fileExtension)"
                    
                } else {
                    screenshotName = "\(self.appSettings.saveDirectoryName!) - \(now) - \(increment) - \(incrementer!).\(fileExtension)"
                }
                
                screenshotFullName = "\(screenshotPath)/\(screenshotName)"
                screenshotNameFullURL = screenshotFullName.replacingOccurrences(of: " ", with: "%20")
             
                z += 1
                
                
            }
            
            let screenshotURL = URL(string: screenshotNameFullURL)
            if(writeFile) {
                
                let content = "Blank image."
                do {
                    try content.write(to: screenshotURL!, atomically: false, encoding: String.Encoding.utf8)
                    urls.append(screenshotURL!)
                }
                catch {/* error handling here */ }
            }
        
            i += 1
            
        }
        
        // Create the files.
        return urls
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
    
    func saveImageBurst(image: CGImage,
                        url: URL,
                        fileExtension: String,
                        preserveLocation: Bool,
                        location: [Double],
                        preserveDate: Bool,
                        fileDate: Date) -> Bool {
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
            
            do {
                try FileManager.default.createDirectory(atPath: self.screenshotPath, withIntermediateDirectories: true, attributes: nil)
            } catch _ as NSError {
                print("Error while creating the frames folder.")
            }
            
            let nsImage = NSImage(cgImage: cgImage!, size: (ciImage?.extent.size)!)
        
            // let data = self.pngData(img: nsImage)
            
            var data = Data()
            
            if(fileExtension == "jpg") {
                data = nsImage.imageJPGRepresentation()! as Data
            } else {
                data = nsImage.imagePNGRepresentation()! as Data
            }
            
            if self.imageWrite(data: data as Data , to: url, options: .atomic) {
                
                print("Screenshot File saved")
                
                if(preserveLocation) {
                    if(self.exifWriteData(url: url, coordinates: location)) {
                        print("Wrote exif... to \(url.path)")
                    }
                }
                
                
                if(preserveDate) {
                    do {
                        
                        let newDate = fileDate
                        let attributes = [
                            FileAttributeKey.creationDate: newDate,
                            FileAttributeKey.modificationDate: newDate
                        ]
                        
                        do {
                            try FileManager.default.setAttributes(attributes, ofItemAtPath: url.path)
                            print("File date updated...")
                        } catch {
                            print(error)
                        }
                    }
                }
                
              
                
                // self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
                
                return true
            } else {
                print("Screenshot File saved FAILED")
    
                return false
            }
        }
    }

    
    
    func saveImage(image: CGImage, outputURL: URL!, videoURL: URL!, currentTime: CMTime) -> Bool {
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
            
            dateformatter.dateFormat = "HHmm.ss.SSSS"
            
            let offsetFloat = CMTimeGetSeconds(currentTime)
            
            print("Offset Float: \(offsetFloat)")
            
            let fileDate = fileFun.getFileModificationDate(originalFile: videoURL, offset: offsetFloat)
            
            do {
                try FileManager.default.createDirectory(atPath: self.appDelegate.appSettings.screenShotFolder, withIntermediateDirectories: true, attributes: nil)
            } catch _ as NSError {
                print("Error while creating a folder.")
            }
            
            let nsImage = NSImage(cgImage: cgImage!, size: (ciImage?.extent.size)!)
            
            var data = Data()
            
            if(self.appSettings.screenshotTypeJPG) {
                data = nsImage.imageJPGRepresentation()! as Data
            } else {
                data = nsImage.imagePNGRepresentation()! as Data
            }
            
            if self.imageWrite(data: data as Data , to: outputURL, options: .atomic) {
                
                print("Screenshot File saved")
                
                if(self.appSettings.screenshotPreserveVideoLocation) {
                    if(self.exifWriteData(url: outputURL!, coordinates: [self.latitude!, self.longitude!])) {
                        print("Wrote exif data")
                    }
                }

                if(self.appSettings.screenshotPreserveVideoDate) {
                    do {
                        let newDate = fileDate
                        let attributes = [
                            FileAttributeKey.creationDate: newDate,
                            FileAttributeKey.modificationDate: newDate
                        ]
                        
                        do {
                            try FileManager.default.setAttributes(attributes, ofItemAtPath: outputURL.path)
                            
                            print("\(outputURL.path)")
                            print("File date updated...")
                        } catch {
                            print(error)
                        }
                    }
                }
                
               
                
                // self.appDelegate.fileBrowserViewController.reloadFilesWithSelected(fileName: "")
            
                return true
            } else {
                print("Screenshot File FAILED")
                
                return false
            }
        }
    }
    
    
    func exifWriteData(url: URL, coordinates: [Double?]) -> Bool {
        
        print("Coordinates \(coordinates)")
        
        var latArg = "-GPSLatitude="
        var latRefArg = "-GPSLatitudeRef="
        if var lat = coordinates[0] {
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
        
        if var lon = coordinates[1] {
            if lon < 0 {
                lonRefArg += "W"
                lon = -lon
            } else {
                lonRefArg += "E"
            }
            lonArg += "\(lon)"
        }
        
        // var output : [String] = []
        var error : [String] = []

        let exiftool = Process()
        exiftool.launchPath = "/usr/local/bin/exiftool"
        exiftool.arguments = ["-m",
                              "-DateTimeOriginal<FileModifyDate", latArg, latRefArg,
                              lonArg, lonRefArg, "\(url.path)"]
        
        
        exiftool.arguments?.insert("-overwrite_original", at: 2)
        
        // print("ARGUMENTS \(String(describing: exiftool.arguments))")

        
        // let outpipe = Pipe()
        // exiftool.standardOutput = outpipe
        let errpipe = Pipe()
        exiftool.standardError = errpipe
        exiftool.launch()
        
//        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
//        if var string = String(data: outdata, encoding: .utf8) {
//            // string = string.trimmingCharacters(in: .newlines)
//            // output = string.components(separatedBy: "\n")
//            
//            // print("exif output: \(output)")
//
//        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
            
            if(string.characters.count > 0) {
                print("exif error: \(error)")
            }
            
        }
        
        exiftool.waitUntilExit()
        let status = exiftool.terminationStatus
        
        
        if(status == 1) {
            return true
        } else {
            return false
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
