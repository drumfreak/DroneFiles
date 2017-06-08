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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate.mediaMapViewController = self
        managedObjectContext = self.appDelegate.persistentContainer.viewContext

        
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = self.appSettings.appViewBackgroundColor.cgColor
        
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor
        self.mapView.delegate = self
  
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.window?.titleVisibility = NSWindowTitleVisibility.hidden
        self.window.backgroundColor = self.appSettings.tableRowActiveBackGroundColor
        self.window?.orderFront(self.view.window)
        self.window?.becomeFirstResponder()
        self.window?.titlebarAppearsTransparent = true

        // loadVideos()

    }
    
    
    func loadVideos(currentURL: URL) {
        
        let fetch = self.fecthVideoFileRequest
        fetch.predicate = NSPredicate(format: "videoLocation != %@",
        "")
        
        do {
            let videos = try managedObjectContext.fetch(fetch)
            
            self.videoCountLabel?.title = "\(videos.count)"
            
            if(videos.count > 0) {
                
                var i = 0
                videos.forEach({ v in
                    i += 1
                    
                    let video = v as! VideoFile
                    // show artwork on map
                    
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .medium
                    let dateLabel = "\(dateFormatter.string(from: video.fileDate! as Date))"
                    
            
                    
                    let videoItem = VideoMapItem(title: dateLabel,
                                                 locationName: video.fileName!,
                                                 discipline: "Video",
                                                 coordinate: CLLocationCoordinate2D(latitude: video.videoLocationLat, longitude: video.videoLocationLong))
                    
                    mapView.addAnnotation(videoItem)
                    
                    //if(self.currentVideoUrl) {
                    
                    if(URL(string: video.fileUrl!) == currentURL) {
                        mapView.showAnnotations([videoItem], animated: true)
                    }
                    
                    
                    // }
                })
                

            }
            
        } catch let error as NSError {
            print("Could not fetch Video. \(error), \(error.userInfo)")
            //            return VideoFile()
        }
        
    }
}


class VideoMapItem: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
