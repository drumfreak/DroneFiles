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
    
        var videoWriter: AVAssetWriter?
        var videoOutputUrl: URL
    
    
    init(photoURLs: [String], url: String) {
            self.photoURLs = photoURLs
            self.videoOutputUrl = URL(string: url)!
        }
        
        func build(_ progress: @escaping ((Progress) -> Void), success: @escaping ((URL) -> Void), failure: @escaping ((NSError) -> Void)) {
            let inputSize = CGSize(width: 4000, height: 3000)
            let outputSize = CGSize(width: 1920, height: 1080)
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
                let videoSettings: [String : AnyObject] = [
                    AVVideoCodecKey  : AVVideoCodecH264 as AnyObject,
                    AVVideoWidthKey  : outputSize.width as AnyObject,
                    AVVideoHeightKey : outputSize.height as AnyObject,
                    //        AVVideoCompressionPropertiesKey : [
                    //          AVVideoAverageBitRateKey : NSInteger(1000000),
                    //          AVVideoMaxKeyFrameIntervalKey : NSInteger(16),
                    //          AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
                    //        ]
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
                        let fps: Int32 = 30
                        let frameDuration = CMTimeMake(1, fps)
                        let currentProgress = Progress(totalUnitCount: Int64(self.photoURLs.count))
                        
                        var frameCount: Int64 = 0
                        var remainingPhotoURLs = [String](self.photoURLs)
                        
                        while videoWriterInput.isReadyForMoreMediaData && !remainingPhotoURLs.isEmpty {
                            let nextPhotoURL = remainingPhotoURLs.remove(at: 0)
                            let lastFrameTime = CMTimeMake(frameCount, fps)
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
                    let imageData = try? Data(contentsOf: url),
                    let image = NSImage(data: imageData),
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
