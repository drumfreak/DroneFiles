//
//  MediaMapWindowController.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 6/7/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import MapKit
import CoreData

class MediaMapWindowController: NSWindowController {
    @IBOutlet weak var toolBar: NSToolbar!
    override var windowNibName: String? {
        return "MediaMapWindowController" // no extension .xib here
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}


class MediaMapViewController: NSViewController, MKMapViewDelegate {
    @IBOutlet var window: NSWindow!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var videoCountLabel: NSButton!
    var managedObjectContext: NSManagedObjectContext!
    var videoFiles: [VideoFile] = []
    var fecthVideoFileRequest = NSFetchRequest<NSManagedObject>(entityName: "VideoFile")
    var currentVideoUrl: URL?
    var currentVideoItem: VideoMapItem!
    var viewIsOpen = false
    var clickedItem: VideoMapItem!
    var videoItems = [VideoMapItem]()
    var fileFun = FileFunctions()
    var autoPlay = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.mediaMapViewController = self
        managedObjectContext = self.appDelegate.persistentContainer.viewContext

        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        //self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        //self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor
        self.mapView.delegate = self
        // self.mapView.animator().alphaValue = 0.5

    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.viewIsOpen = true
        if(self.currentVideoUrl != nil) {

            self.loadVideos(currentURL: self.currentVideoUrl!)
            
        }
//        
//        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
//        self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor
//        self.window?.orderFront(self.view.window)
//        self.window?.becomeFirstResponder()
//        self.window?.titlebarAppearsTransparent = true
//        self.mapView.showsScale = true
//        self.mapView.showsPointsOfInterest = true
//        self.mapView.showsBuildings = true

        // loadVideos()

    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.viewIsOpen = false
    }

    
    
    func loadVideos(currentURL: URL) {
        self.currentVideoItem = nil
        self.currentVideoUrl = currentURL
        managedObjectContext = self.appDelegate.persistentContainer.viewContext

        let fetch = self.fecthVideoFileRequest
        fetch.predicate = NSPredicate(format: "videoLocation != %@",
        "")
        
        var zoomInOnVideo = false
        do {
            let videos = try managedObjectContext.fetch(fetch)
            
            self.videoCountLabel?.title = "\(videos.count)"
            self.videoItems = [VideoMapItem]()
            
            if(videos.count > 0) {
                var i = 0
                videos.forEach({ v in
                    i += 1
                
                    
                    let video = v as! VideoFile
                    print("VIDEO \(video)")
                    
                    if(self.fileFun.fileExists(url: URL(string: video.fileUrl!)!)) {
                     
                        if(video.videoLocationLat < 0 || video.videoLocationLat > 0) {
                            // show artwork on map
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateStyle = .medium
                            dateFormatter.timeStyle = .medium
                            let dateLabel = "\(dateFormatter.string(from: video.fileDate! as Date))"
                        
                            
                            let videoItem = VideoMapItem(title: dateLabel,
                                                         locationName: video.fileName!,
                                                         discipline: "Video",
                                                         coordinate: CLLocationCoordinate2D(latitude: video.videoLocationLat, longitude: video.videoLocationLong), url: URL(string: video.fileUrl!)!)
                            
                            self.videoItems.append(videoItem)
                            
                            self.mapView.addAnnotation(videoItem)
                            
                            if(URL(string: video.fileUrl!) == currentURL) {
                                self.currentVideoItem = videoItem
                                zoomInOnVideo = true
                            }

                            
                        }
                        
                        
                    }
                    
                })
                

                if(zoomInOnVideo) {
                    var delayInSeconds = 0.0
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                        
                        // here code perfomed with delay
                        let region = MKCoordinateRegion(center: self.currentVideoItem.coordinate, span: MKCoordinateSpan(latitudeDelta:0.9, longitudeDelta: 0.5))
                        
                        self.mapView.selectAnnotation(self.currentVideoItem, animated: false)
                        
                        self.mapView.setRegion(region, animated: true)
                        
                    }
                    
                    //                delayInSeconds = 2.0
                    //                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    //                    
                    //                    // here code perfomed with delay
                    //                    let region = MKCoordinateRegion(center: self.currentVideoItem.coordinate, span: MKCoordinateSpan(latitudeDelta:0.05, longitudeDelta: 0.05))
                    //                    
                    //                    self.mapView.selectAnnotation(self.currentVideoItem, animated: false)
                    //                    
                    //                    self.mapView.setRegion(region, animated: true)
                    //                    
                    //                }

                    delayInSeconds = 1.5
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {

                        let region = MKCoordinateRegion(center: self.currentVideoItem.coordinate, span: MKCoordinateSpan(latitudeDelta:0.005, longitudeDelta: 0.005))
                        
                        self.mapView.selectAnnotation(self.currentVideoItem, animated: false)
                        
                        self.mapView.setRegion(region, animated: true)
                    }
                }
            }
            
        } catch let error as NSError {
            print("Could not fetch Video. \(error), \(error.userInfo)")
            //            return VideoFile()
        }
    }
    
    @IBAction func toggleAutoPlay(sender: AnyObject) {
        self.autoPlay = !self.autoPlay
    }

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Capital"
        // var i = 0
        //if annotation is Capital {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:identifier)
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                let item = annotation as! VideoMapItem
                let btn = annoButton(title: "View", target: self, action: #selector(self.openVideoFromCallout))
                //let btnTag = ()
                
                btn.url = item.url
                
                
                annotationView.rightCalloutAccessoryView = btn
                return annotationView
            }
        //}
        
        // return nil
    }
    
   
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if(self.autoPlay) {
            let viewItem = view.annotation as! VideoMapItem
            
            guard let url = viewItem.url else {
                print("something went wrong, element. Name can not be cast to String")
                return
            }
            
            print(url)
            
            if(url != self.currentVideoUrl) {
                
                // self.appDelegate.videoPlayerViewController.
                self.appDelegate.videoPlayerViewController?.loadVideoFromMap(url: url)
                self.appDelegate.videoControlsController.currentVideoURL = url
                self.appDelegate.videoControlsController.nowPlayingURLString = url.absoluteString
                self.appDelegate.videoControlsController.nowPlayingFile.stringValue = url.lastPathComponent
                self.appDelegate.appSettings.lastFileOpened = url.absoluteString
                self.appDelegate.secondaryDisplayMediaViewController?.loadVideo(videoUrl: url)
                self.appDelegate.saveProject()
                
            }
            
        }
        
        
    }
    
  
    
    
    @IBAction func openVideoFromCallout(sender: annoButton) {
      
        // print("SENDER: \(sender.url)")
        
        if(sender.url == nil) {
            return
        }
        
        guard let url = sender.url else {
            print("something went wrong, element. Name can not be cast to String")
            return
        }
        
        // print(url)

        if(url != self.currentVideoUrl) {
            
                // self.appDelegate.videoPlayerViewController.
            
            
            self.appDelegate.videoPlayerViewController?.loadVideoFromMap(url: url)
            self.appDelegate.videoControlsController.currentVideoURL = url
            self.appDelegate.videoControlsController.nowPlayingURLString = url.absoluteString
            self.appDelegate.videoControlsController.nowPlayingFile.stringValue = url.lastPathComponent
            self.appDelegate.appSettings.lastFileOpened = url.absoluteString
            self.appDelegate.secondaryDisplayMediaViewController?.loadVideo(videoUrl: url)
            self.appDelegate.saveProject()
        
        }
        
    }
    
    
}


class annoButton: NSButton {
    var url: URL!
    
    
    
}

class VideoMapItem: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    let url: URL!

    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D, url: URL) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        self.url = url
        
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
