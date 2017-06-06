//
//  TimeLapseBuilder.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 5/29/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa
import AVFoundation

let kErrorDomain = "TimeLapseBuilder"
let kFailedToStartAssetWriterError = 0
let kFailedToAppendPixelBufferError = 1

class TimeLapseBuilder: NSObject {
    let photoURLs: [String]
    var outputUrl =  ""
    var outputSize = CGSize(width: 1920, height: 1080)
    var frameRate = Int32(30)
    var videoWriter: AVAssetWriter?
    var videoOutputUrl: URL
    
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    init(photoURLs: [String], url: String) {
        self.photoURLs = photoURLs
        self.videoOutputUrl = URL(string: url)!
    }
    
    func build(frameRate: Int32, outputSize: CGSize,_ progress: @escaping ((Progress) -> Void), success: @escaping ((URL) -> Void), failure: @escaping ((NSError) -> Void)) {
        
        self.outputSize = outputSize
        self.frameRate = frameRate
        
        let inputSize = CGSize(width: outputSize.width, height: outputSize.height)
        var error: NSError?
        
        let path = self.videoOutputUrl.deletingLastPathComponent()
        
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
        } catch _ as NSError {
            print("Error while creating timelapse folder.")
        }
        
        //            do {
        //                try FileManager.default.removeItem(at: videoOutputUrl)
        //            } catch {}
        //
        do {
            try videoWriter = AVAssetWriter(outputURL: videoOutputUrl, fileType: AVFileTypeQuickTimeMovie)
        } catch let writerError as NSError {
            error = writerError
            videoWriter = nil
        }
        
        if let videoWriter = videoWriter {
            
            let compressionSettings:[String : AnyObject] = [
//                AVVideoAverageBitRateKey : 1000000 as AnyObject,
//                AVVideoMaxKeyFrameIntervalKey : 16 as AnyObject,
//                AVVideoProfileLevelKey :
            :]
            
            let videoSettings: [String : AnyObject] = [
                AVVideoCodecKey  : AVVideoCodecH264 as AnyObject,
                AVVideoWidthKey  : outputSize.width as AnyObject,
                AVVideoHeightKey : outputSize.height as AnyObject,
                AVVideoCompressionPropertiesKey : compressionSettings as AnyObject
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
            
            
            let sourceBufferAttributes = [
                (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
                (kCVPixelBufferWidthKey as String): Float(inputSize.width),
                (kCVPixelBufferHeightKey as String): Float(inputSize.height)] as [String : Any]
            
            let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: videoWriterInput,
                sourcePixelBufferAttributes: sourceBufferAttributes
            )
            
            assert(videoWriter.canAdd(videoWriterInput))
            videoWriter.add(videoWriterInput)
            
            if videoWriter.startWriting() {
                videoWriter.startSession(atSourceTime: kCMTimeZero)
                assert(pixelBufferAdaptor.pixelBufferPool != nil)
                
                let media_queue = DispatchQueue(label: "mediaInputQueue")
                
                videoWriterInput.requestMediaDataWhenReady(on: media_queue) {
                    let frameDuration = CMTimeMake(1, frameRate)
                    let currentProgress = Progress(totalUnitCount: Int64(self.photoURLs.count))
                    
                    var frameCount: Int64 = 0
                    var remainingPhotoURLs = [String](self.photoURLs)
                    
                    while videoWriterInput.isReadyForMoreMediaData && !remainingPhotoURLs.isEmpty {
                        let nextPhotoURL = remainingPhotoURLs.remove(at: 0)
                        let lastFrameTime = CMTimeMake(frameCount, frameRate)
                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                        
                        if !self.appendPixelBufferForImageAtURL(nextPhotoURL, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                            error = NSError(
                                domain: kErrorDomain,
                                code: kFailedToAppendPixelBufferError,
                                userInfo: ["description": "AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer"]
                            )
                            
                            break
                        }
                        
                        frameCount += 1
                        
                        currentProgress.completedUnitCount = frameCount
                        progress(currentProgress)
                    }
                    
                    videoWriterInput.markAsFinished()
                    videoWriter.finishWriting {
                        if let error = error {
                            failure(error)
                        } else {
                            success(self.videoOutputUrl)
                        }
                        
                        self.videoWriter = nil
                    }
                }
            } else {
                error = NSError(
                    domain: kErrorDomain,
                    code: kFailedToStartAssetWriterError,
                    userInfo: ["description": "AVAssetWriter failed to start writing"]
                )
            }
        }
        
        if let error = error {
            failure(error)
        }
    }
    
    func appendPixelBufferForImageAtURL(_ url: String, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var appendSucceeded = false
        
        autoreleasepool {
            if let url = URL(string: url),
                let image = NSImage(contentsOf: url)?.resizeImage(width: outputSize.width, height: outputSize.height),
                // let imageData = try? Data(contentsOf: url),
                let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixelBufferPool,
                    pixelBufferPointer
                )
                
                if let pixelBuffer = pixelBufferPointer.pointee, status == 0 {
                    fillPixelBufferFromImage(image, pixelBuffer: pixelBuffer)
                    
                    appendSucceeded = pixelBufferAdaptor.append(
                        pixelBuffer,
                        withPresentationTime: presentationTime
                    )
                    
                    pixelBufferPointer.deinitialize()
                } else {
                    NSLog("error: Failed to allocate pixel buffer from pool")
                }
                
                pixelBufferPointer.deallocate(capacity: 1)
            }
        }
        
        return appendSucceeded
    }
    
    func fillPixelBufferFromImage(_ image: NSImage, pixelBuffer: CVPixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        context?.draw(image.CGImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
    }
}


class RetimeBuilder: NSObject {
    var outputUrl: URL!
    var outputSize = CGSize(width: 1920, height: 1080)
    var frameRate = Int32(30)
    var asset: AVAsset!
    
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    init(asset: AVAsset, url: URL) {
        self.outputUrl = url
        self.asset = asset
        //self.videoOutputUrl = URL(string: url)!
        
    }
    
    func getProgress() -> Double {
        return 0.1
    }
    func build(frameRate: Int32, outputSize: CGSize,_ progress: @escaping ((Progress) -> Void), success: @escaping ((URL) -> Void), failure: @escaping ((NSError) -> Void)) {
        
        // print("OUTPUT URL \(self.outputUrl)")
        

        let exportSession = AVAssetExportSession(asset: self.asset, presetName: AVAssetExportPresetHighestQuality)!
        
        // self.exportSession.videoComposition = videoComposition
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.outputURL = self.outputUrl // Output URL
        
        let videoTrack: AVAssetTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, frameRate)
        videoComposition.renderSize = outputSize
       
        let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction.init()
    
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        
        let transformer: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack);
        
        let firstTransform = videoTrack.preferredTransform
        
        // Check the first video track's preferred transform to determine if it was recorded in portrait mode.
        if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
            // isVideoPortrait = true
        }
        
        let size = videoTrack.naturalSize;
        
        if(outputSize.width != size.width && outputSize.height != size.height) {

            let scaleToFitRatio = outputSize.width / videoTrack.naturalSize.width

            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            // print("SCALE TO THIS RATIO: \(scaleToFitRatio)")
            
            let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            
            // let yFix = videoTrack.naturalSize.height + outputSize.height
            
            let leftOffset = videoTrack.naturalSize.width * scaleToFitRatio / 2
            
            let topOffset = videoTrack.naturalSize.height * scaleToFitRatio / 2
            
            let centerFix = CGAffineTransform(translationX: leftOffset, y: topOffset)
        
            videoLayerInstruction.setTransform(firstTransform.concatenating(scaleFactor.concatenating(centerFix)),
                                     at: kCMTimeZero)
            
            // videoLayerInstruction.setTransform(firstTransform, at: kCMTimeZero)
            
            instruction.layerInstructions.append(videoLayerInstruction)
            
            //Apply any transformer if needed
            
        }
    
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        exportSession.videoComposition = videoComposition

        
        let currentProgress = Progress(totalUnitCount: 100)
        currentProgress.completedUnitCount = 0
        progress(currentProgress)
        var isComplete = false
        // progress
        exportSession.exportAsynchronously {
            switch exportSession.status {
                case .exporting:
                        // print("~~~~~~~~~ EXPORTING")
                    break
                case .completed:
                    DispatchQueue.main.async {
                        // success(self.outputUrl)
                        currentProgress.completedUnitCount = 100
                        progress(currentProgress)
                    }
                    break
                case .failed:
                    DispatchQueue.main.async {
                        failure(exportSession.error! as NSError)
                        print(exportSession.error!)
                        
                        // self.clipTrimTimer.invalidate()
                        currentProgress.completedUnitCount = 0
                        progress(currentProgress)
                    }
                    break
                default:
                    DispatchQueue.main.async {
                        // self.clipTrimTimer.invalidate()
                        failure(exportSession.error! as NSError)
                        currentProgress.completedUnitCount = 0
                        progress(currentProgress)
                    }
                break
            }
        }
        
        var i = 0

        while exportSession.status == .waiting || exportSession.status == .exporting {
        
            if(i < 100) {
                // print("Progress: \(exportSession.progress * 100.0)%.")
                currentProgress.completedUnitCount = Int64(exportSession.progress * 100.0)
                progress(currentProgress)
                i = i + 1
                
            } else {
                i = 0
            }
            
            if(exportSession.progress == 1 && isComplete == false) {
                    if(!isComplete) {
                        success(self.outputUrl)
                        isComplete = true
                    }
                
            }
        }
    }
}



class ClipTrimBuilder: NSObject {
    var outputUrl: URL!
    var outputSize = CGSize(width: 1920, height: 1080)
    var frameRate = Int32(30)
    var timeRange: CMTimeRange!
    var asset: AVAsset!
    
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    init(asset: AVAsset, url: URL) {
        self.outputUrl = url
        self.asset = asset
        //self.videoOutputUrl = URL(string: url)!
        
    }
    
    func getProgress() -> Double {
        return 0.1
    }
    func build(timeRange: CMTimeRange, frameRate: Int32, outputSize: CGSize,_ progress: @escaping ((Progress) -> Void), success: @escaping ((URL) -> Void), failure: @escaping ((NSError) -> Void)) {
        
        // print("OUTPUT URL \(self.outputUrl)")
        
        let exportSession = AVAssetExportSession(asset: self.asset, presetName: AVAssetExportPresetHighestQuality)!
        
        // self.exportSession.videoComposition = videoComposition
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.outputURL = self.outputUrl // Output URL
        exportSession.timeRange = timeRange
        
        let currentProgress = Progress(totalUnitCount: 100)
        currentProgress.completedUnitCount = 0
        progress(currentProgress)
        var isComplete = false
        // progress
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .exporting:
                // print("~~~~~~~~~ EXPORTING")
                break
            case .completed:
                DispatchQueue.main.async {
                    // success(self.outputUrl)
                    currentProgress.completedUnitCount = 100
                    progress(currentProgress)
                }
                break
            case .failed:
                DispatchQueue.main.async {
                    failure(exportSession.error! as NSError)
                    print(exportSession.error!)
                    
                    // self.clipTrimTimer.invalidate()
                    currentProgress.completedUnitCount = 0
                    progress(currentProgress)
                }
                break
            default:
                DispatchQueue.main.async {
                    // self.clipTrimTimer.invalidate()
                    failure(exportSession.error! as NSError)
                    currentProgress.completedUnitCount = 0
                    progress(currentProgress)
                }
                break
            }
        }
        
        var i = 0
        
        while exportSession.status == .waiting || exportSession.status == .exporting {
            
            if(i < 100) {
                // print("Progress: \(exportSession.progress * 100.0)%.")
                currentProgress.completedUnitCount = Int64(exportSession.progress * 100.0)
                progress(currentProgress)
                i = i + 1
                
            } else {
                i = 0
            }
            
            if(exportSession.progress == 1 && isComplete == false) {
                if(!isComplete) {
                    success(self.outputUrl)
                    isComplete = true
                }
                
            }
        }
    }
}




class VideoFrameBurstBuilder: NSObject {
    var outputUrl: URL!
    var outputSize = CGSize(width: 1920, height: 1080)
    var frameRate = Int32(30)
    var timeRange: CMTimeRange!
    var asset: AVAsset!
    var fileFun = FileFunctions()

    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    init(asset: AVAsset, url: URL) {
        self.outputUrl = url
        self.asset = asset
        //self.videoOutputUrl = URL(string: url)!
    }
    
    func getProgress() -> Double {
        return 0.1
    }
    
    func build(startTime: CMTime,
               assetUrl: URL!,
               interval: Double,
               framesBefore: Int32,
               framesAfter: Int32,
               preserveName: Bool,
               preserveDate: Bool,
               preserveLocation: Bool,
               outputSize: CGSize,
               _ progress: @escaping ((Progress, URL) -> Void),
               success: @escaping ((URL) -> Void),
               failure: @escaping ((NSError) -> Void)) {
        
//        print("Burst assetURL: \(assetUrl.absoluteURL)")
//        print("Burst startTime: \(startTime.seconds)")
//        print("Burst interval: \(interval)")
//        print("Burst framesBefore: \(framesBefore)")
//        print("Burst framesAfter: \(framesAfter)")
//        print("Burst preserveName: \(preserveName)")
//        print("Burst preserveDate: \(preserveDate)")
//        print("Burst preserveLocation: \(preserveLocation)")
//        print("Burst outputSize: \(outputSize)")
        
        var times = [CMTime]()

        var i = Int64(framesBefore)
        var playerTime1: CMTime!
        
        while(i > 0) {
            let oneFrame = CMTimeMakeWithSeconds((Double(i) * interval), startTime.timescale);
            
            playerTime1 = CMTimeSubtract(startTime, oneFrame);
            
            if(playerTime1 >= kCMTimeZero) {
                times.append(playerTime1)
            }
            
            i -= 1
        }
        
        i = 0
        
        times.append(startTime)
        
        while(i < Int64(framesAfter)) {
            let oneFrame = CMTimeMakeWithSeconds((Double(i) * interval), startTime.timescale);
            playerTime1 = CMTimeAdd(startTime, oneFrame);
            
            if(playerTime1 <= self.asset.duration) {
                times.append(playerTime1)
            }

            i += 1
        }

        times.forEach({time in
            print("Time: \(time.seconds)")
        })
        
        // print("Times \(times)")
        var fileExtension = "png"
        if(self.appDelegate.appSettings.screenshotTypeJPG) {
            fileExtension = "jpg"
        }
        
        let urls = self.appDelegate.screenshotViewController.getScreenshotPathsForBurst(assetUrl: assetUrl, startTime: startTime, times: times, numFiles: times.count, fileExtension: fileExtension, preserveVideoName: self.appDelegate.appSettings.screenshotPreserveVideoName, writeFile: true)
        
        let currentProgress = Progress(totalUnitCount: Int64(times.count))
        
        currentProgress.completedUnitCount = 0
        progress(currentProgress, (urls?[0])!)
        
        i = 0
        self.appDelegate.screenshotViewController.generateThumbnailsForBurst(
            asset: self.asset,
            assetUrl:  assetUrl,
            startTime: startTime,
            times: times,
            urls: urls!,
            fileExtension: fileExtension,
            preserveLocation: self.appDelegate.appSettings.screenshotPreserveVideoLocation,
            preserveDate: preserveDate,
            fileDate: fileFun.getFileModificationDate(originalFile: assetUrl,offset: 0),
            { prog, url in
            // workerItem.inProgress = true
            // workerItem.percent = (progress.fractionCompleted * 100.0)
            i += 1
                
                
            currentProgress.completedUnitCount = i
                
            // print("UNIT COUNT  \(currentProgress.completedUnitCount)")
            
            progress(currentProgress, url)
        
        }, success: { url in
            i += 1
                DispatchQueue.main.async {
                    success(self.outputUrl)
                    currentProgress.completedUnitCount = Int64(times.count)
                    progress(currentProgress, (urls?[0])!)
                }
        }, failure: { error in
            i += 1
            print("ERROR \(error)")
            failure(error as NSError)
            currentProgress.completedUnitCount = 0
            progress(currentProgress, (urls?[0])!)
        })

    }
}




