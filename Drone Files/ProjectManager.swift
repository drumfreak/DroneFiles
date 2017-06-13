//
//  ProjectManager.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 6/13/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Foundation
import Cocoa
import AVKit
import AppKit
import AVFoundation
import Quartz
import CoreData

class ProjectManager: NSObject {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var videoFiles: [VideoFile] = []
    
    var project: Project!
    
    var fecthProjectRequest = NSFetchRequest<NSManagedObject>(entityName: "Project")
    
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    var appSettings:AppSettings {
        return appDelegate.appSettings
    }
    
    override init() {
        
    }
    
    
    
    
    func getProject(url: URL!, projectName: String) -> Project {
        
        managedObjectContext = self.appDelegate.persistentContainer.viewContext
        
        let fetch = self.fecthProjectRequest
        fetch.predicate = NSPredicate(format: "projectPath == %@", url.path)
        
        do {
            let projects = try managedObjectContext.fetch(fetch)
            
            if(projects.count > 0) {
                let project = projects[0] as! Project
                print("Project Found: \(String(describing: project.projectName))")
                return project
            } else {
                let entity =
                    NSEntityDescription.entity(forEntityName: "Project",
                                               in: managedObjectContext)!
                
                let project = NSManagedObject(entity: entity,
                                            insertInto: managedObjectContext) as! Project
                
                // 3
                project.created = NSDate()
                project.lastOpened = NSDate()
                project.projectPath = url.path
                project.projectName = projectName
                
                // 4
                do {
                    try managedObjectContext.save()
                    
                    return project
                } catch let error as NSError {
                    print("Could not saving Project. \(error), \(error.userInfo)")
                    return Project()
                }
                
                
            }
            
        } catch let error as NSError {
            
            print("Could not fetch Project. \(error), \(error.userInfo)")
            
            return Project()
            
        }
        
    }
    
    
    func removeProject(url: URL) {
        
        
        
    }
    
}
