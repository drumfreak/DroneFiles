//
//  AppDelegate.swift
//  Drone Files
//
//  Created by Eric Rosebrock on 4/18/17.
//  Copyright © 2017 The Web Freaks, INC. All rights reserved.
//

import Cocoa
import AVFoundation
import Quartz


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    @IBOutlet var window: NSWindow!
    var defaults = UserDefaults.standard

    var externalScreens = [NSScreen]()
    
    var appSettings = AppSettings()
    var documentController = NSDocumentController.shared()
    
    // TODO: Eventually load all these view controllers from storyboard
    // @IBOutlet var editorTabViewController: EditorTabViewController!
    @IBOutlet var splitViewController: SplitViewController!
    @IBOutlet var fileBrowserViewController: FileBrowserViewController!
    @IBOutlet var fileManagerViewController: FileManagerViewController!
  
    @IBOutlet weak var fileManagerOptionsTabViewController : FileManagerOptionsTabViewController!
    @IBOutlet weak var fileManagerOptionsCopyController: FileManagerOptionsCopyController!
    @IBOutlet weak var fileManagerOptionsOrganizeController: FileManagerOptionsOrganizeController!
    @IBOutlet weak var fileManagerOptionsMoveController: FileManagerOptionsMoveController!
    @IBOutlet weak var fileManagerOptionsRenameController: FileManagerOptionsRenameController!
    @IBOutlet weak var fileManagerOptionsDeleteController: FileManagerOptionsDeleteController!
    
    @IBOutlet weak var screenShotSliderController: ScreenShotSliderController!
    
    @IBOutlet weak var favoritesCollectionViewController: FavoritesCollectionViewController!
    
    @IBOutlet weak var favoritesViewController: FavoritesViewController!
 
    let fileCopyProgressView = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "fileCopyProgressView") as! FileCopyProgressIndicatorController
    
    
//    @IBOutlet weak var windowController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "windowController") as? WindowController
    
    
    @IBOutlet weak var editorTabViewController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "editorTabViewController") as? EditorTabViewController
    
    @IBOutlet var videoPlayerControlsController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "videoPlayerControlsController") as? VideoPlayerControllsController
    
    @IBOutlet weak var videoPlayerViewController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "videoPlayerViewController") as? VideoPlayerViewController

    @IBOutlet weak var imageEditorViewController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "imageEditorViewController") as? ImageEditorViewController
    
    @IBOutlet weak var imageEditorControlsController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "imageEditorControlsController") as? ImageEditorControllsController
    
    var screenshotViewController = ScreenshotViewController()
    
    @IBOutlet weak var videoSplitViewController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "videoSplitViewController") as? VideoSplitViewController
    //
    @IBOutlet weak var slideShowController = NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "slideShowController") as? SlideShowController

    
    
    @IBOutlet weak var secondWindowController = SecondWindowController()
    @IBOutlet weak var secondaryDisplayMediaViewController = SecondaryDisplayMediaViewController()

        //NSStoryboard.init(name: "Main", bundle: nil).instantiateController(withIdentifier: "secondWindowController") as? SecondWindowController

    
    var slideShowWindowController: SlideShowWindowController?

    var slideshowUrls = NSMutableArray()

    // Variables setup for various usage.

    func applicationWillResignActive(_ notification: Notification) {
        
    }
    
    func applicationWillHide(_ notification: Notification) {
        
    }
    
    func applicationDidUpdate(_ notification: Notification) {
        
    }
    
    func applicationDidResignActive(_ notification: Notification) {

    }
    
    func saveProject() {
        self.writeProjectFile(projectPath: self.appSettings.projectFolder)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    
        // Swift.print(appSettings)
        setupOptions()
       
        let notification = NSUserNotification()
        notification.title = "Welcome to DroneFiles!"
        notification.informativeText = "Your life will never be the same"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
        
        self.externalScreens = NSScreen.externalScreens()

       
    }
    

    
    func setupOptions() {
        let defaults = UserDefaults.standard
        //defaults.setValue([], forKey: "mediaBinUrls")
        //defaults.setValue([], forKey: "favoriteUrls")

        if(defaults.value(forKey: "screenshotPreserveVideoName") == nil) {
            defaults.setValue(true, forKey: "screenshotSound")
            defaults.setValue(true, forKey: "screenshotPreserveVideoName")
            defaults.setValue(true, forKey: "screenshotTypeJPG")
            defaults.setValue(false, forKey: "screenshotTypePNG")
            defaults.setValue(true, forKey: "screenshotPreview")
            defaults.setValue(true, forKey: "screenShotBurstEnabled")
            defaults.setValue(true, forKey: "clippedItemPreserveFileDates")
            defaults.setValue(true, forKey: "screenshotPreserveVideoDate")
            defaults.setValue(true, forKey: "screenshotPreserveVideoLocation")
            defaults.setValue(0.1, forKey: "screenshotFramesInterval")
            defaults.setValue(5, forKey: "screenshotFramesAfter")
            defaults.setValue(5, forKey: "screenshotFramesBefore")
            defaults.setValue(0.2, forKey: "mediaBinTimerInterval")
            defaults.setValue(false, forKey: "loadNewClip")
            defaults.setValue(true, forKey: "videoPlayerAutoPlay")
            defaults.setValue(true, forKey: "videoPlayerAlwaysPlay")
            defaults.setValue(false, forKey: "videoPlayerLoop")
            defaults.setValue(false, forKey: "videoPlayerLoopAll")
        }
        
        if(defaults.value(forKey: "lastProjectfileOpened") != nil) {
            self.readProjectFile(projectFile: defaults.value(forKey: "lastProjectfileOpened") as! String)
        } else {
            
            
            // print(defaults)
            
            if(defaults.value(forKey: "thumbnailDirectory") != nil) {
                self.appSettings.thumbnailDirectory = (defaults.value(forKey: "thumbnailDirectory"))! as! String
            }
            
            
            if(defaults.value(forKey: "videoPlayerAutoPlay") != nil) {
                self.appSettings.videoPlayerAutoPlay = (defaults.value(forKey: "videoPlayerAutoPlay"))! as! Bool
            }
            
            
            if(defaults.value(forKey: "videoPlayerAlwaysPlay") != nil) {
                self.appSettings.videoPlayerAlwaysPlay = (defaults.value(forKey: "videoPlayerAlwaysPlay"))! as! Bool
            }
            
            
            if(defaults.value(forKey: "videoPlayerLoop") != nil) {
                self.appSettings.videoPlayerLoop = (defaults.value(forKey: "videoPlayerLoop"))! as! Bool
            }
            
            
            if(defaults.value(forKey: "videoPlayerLoopAll") != nil) {
                self.appSettings.videoPlayerLoopAll = (defaults.value(forKey: "videoPlayerLoopAll"))! as! Bool
            }
            
            if(defaults.value(forKey: "screenshotPreserveVideoName") != nil) {
                self.appSettings.screenshotPreserveVideoName = (defaults.value(forKey: "screenshotPreserveVideoName"))! as! Bool
            }
            
            if(defaults.value(forKey: "screenshotPreserveVideoLocation") != nil) {
                self.appSettings.screenshotPreserveVideoLocation = (defaults.value(forKey: "screenshotPreserveVideoLocation"))! as! Bool
            }
            
            if(defaults.value(forKey: "screenshotSound") != nil) {
                self.appSettings.screenshotSound = (defaults.value(forKey: "screenshotSound"))! as! Bool
            }
            
            if(defaults.value(forKey: "screenShotBurstEnabled") != nil) {
                self.appSettings.screenShotBurstEnabled = (defaults.value(forKey: "screenShotBurstEnabled"))! as! Bool
            }
            
            
            if(defaults.value(forKey: "screenshotPreview") != nil) {
                self.appSettings.screenshotPreview = (defaults.value(forKey: "screenshotPreview"))! as! Bool
            }
            
            if(defaults.value(forKey: "screenshotPreserveVideoDate") != nil) {
                self.appSettings.screenshotPreserveVideoDate = (defaults.value(forKey: "screenshotPreserveVideoDate"))! as! Bool
            }
            
            
            if(defaults.value(forKey: "screenshotTypeJPG") != nil) {
                self.appSettings.screenshotTypeJPG = (defaults.value(forKey: "screenshotTypeJPG"))! as! Bool
            }
            
            
            if(defaults.value(forKey: "screenshotTypePNG") != nil) {
                self.appSettings.screenshotTypePNG = (defaults.value(forKey: "screenshotTypePNG"))! as! Bool
            }
            
            if(defaults.value(forKey: "screenshotFramesBefore") != nil) {
                self.appSettings.screenshotFramesBefore = (defaults.value(forKey: "screenshotFramesBefore"))! as! Int32
            }
            
            if(defaults.value(forKey: "screenshotFramesAfter") != nil) {
                self.appSettings.screenshotFramesAfter = (defaults.value(forKey: "screenshotFramesAfter"))! as! Int32
            }
            
            
            if(defaults.value(forKey: "screenshotTypePNG") != nil) {
                self.appSettings.screenshotTypePNG = (defaults.value(forKey: "screenshotPreserveVideoName"))! as! Bool
            }
            
            
            if(defaults.value(forKey: "screenshotFramesInterval") != nil) {
                self.appSettings.screenshotFramesInterval = (defaults.value(forKey: "screenshotFramesInterval"))! as! Double
            }
            
            
            if(defaults.value(forKey: "mediaBinTimerInterval") != nil) {
                self.appSettings.mediaBinTimerInterval = (defaults.value(forKey: "mediaBinTimerInterval"))! as! Double
            }
            
            if(defaults.value(forKey: "mediaBinUrls") != nil) {
                if let data = defaults.value(forKey: "mediaBinUrls") as? NSData {
                    self.appSettings.mediaBinUrls = (NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [URL])!
                    // print(self.appSettings.mediaBinUrls)
                }
                
                //self.appSettings.mediaBinUrls = []
                
                if(self.appSettings.mediaBinUrls.count > 0) {
                    self.screenShotSliderController.reloadContents()
                    self.screenShotSliderController.selectItemOne()
                }
            }
            
            if(defaults.value(forKey: "favoriteUrls") != nil) {
                if let data = defaults.value(forKey: "favoriteUrls") as? NSData {
                    self.appSettings.favoriteUrls = (NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [URL])!
                    // print(self.appSettings.favoriteUrls)
                }

                if(self.appSettings.favoriteUrls.count > 0) {
                    // self.screenShotSliderController.reloadContents()
                    // self.screenShotSliderController.selectItemOne()
                }
            }
            
            
        }
       
    }
    


    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        self.saveProject()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Drone_Files")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject?) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        let context = persistentContainer.viewContext

        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared().presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
    
    @IBAction func switchToolModeAD(sender: AnyObject) {
        // switch the tool mode...
        
        var newTool = Int(0)
        
        if(sender.isKind(of: NSSegmentedControl.self)) {
            newTool = (sender.selectedSegment)!
        } else {
            newTool = (sender.tag)!
        }
    
        switch newTool {
        case 0:
            self.imageEditorControlsController?.imageView?.currentToolMode = IKToolModeMove
            break
        case 1:
            self.imageEditorControlsController?.imageView.currentToolMode = IKToolModeSelect
            break
        case 2:
            self.imageEditorControlsController?.cropImage(self)
            
            break
        case 3:
            self.imageEditorControlsController?.imageView.currentToolMode = IKToolModeRotate
            break;
        case 4:
           self.imageEditorControlsController?.imageView.currentToolMode = IKToolModeAnnotate
            break
        default:
            self.imageEditorControlsController?.imageView.currentToolMode = IKToolModeNone
            break
            
        }
    }
    
    
    
    @IBAction func openProjectFileAD(sender: AnyObject) {
        self.fileBrowserViewController?.openProjectFile(self);
    }
    
    @IBAction func openThumbnailDirectoryAD(sender: AnyObject) {
        // self.fileBrowserViewController?.openProjectFile(self);
    }
    
    
    @IBAction func takeScreenShotAD(sender: AnyObject) {
        self.videoPlayerControlsController?.takeBurstScreenshotFromKeyboard()
    }
    
    @IBAction func takeScreenShotBurstAD(sender: AnyObject) {
        // self.videoPlayerControlsController?.takeScreenshot(self);
        self.videoPlayerControlsController?.takeBurstScreenshotFromKeyboard();
    }
    
    @IBAction func setVideoTrimInAD(sender: AnyObject) {
        self.videoPlayerControlsController?.setTrimInFromKeyboard()
    }
    
    @IBAction func setVideoTrimOutAD(sender: AnyObject) {
        self.videoPlayerControlsController?.setTrimOutFromKeyboard()
    }
    
    @IBAction func videoFrameDecrementAD(sender: AnyObject) {
        self.videoPlayerControlsController?.frameDecrementFromKeyboard()
    }
    
    @IBAction func videoFrameIncrementAD(sender: AnyObject) {
        self.videoPlayerControlsController?.frameDecrementFromKeyboard()
    }
    
    
    @IBAction func videoPlayPauseAD(sender: AnyObject) {
        self.videoPlayerViewController?.playPause()
    }
    
    
    @IBAction func videoLoopAD(sender: AnyObject) {
        self.appSettings.videoPlayerLoop = !self.appSettings.videoPlayerLoop
    }
    
    
    @IBAction func videoLoopAllAD(sender: AnyObject) {
        self.appSettings.videoPlayerLoopAll = !self.appSettings.videoPlayerLoopAll
    }
    
    @IBAction func videoAutoPlayAD(sender: AnyObject) {
        self.appSettings.videoPlayerAutoPlay = !self.appSettings.videoPlayerAutoPlay
    }
    
    @IBAction func videoAutoPlayAlwaysPlay(sender: AnyObject) {
        self.appSettings.videoPlayerAlwaysPlay = !self.appSettings.videoPlayerAlwaysPlay
    }
    
    @IBAction func addFavoriteAD(sender: AnyObject) {
        self.fileBrowserViewController.addFavorite(nil)
    }
    
    
    func validateUserInterfaceItem(anItem: NSValidatedUserInterfaceItem) -> Bool {
        return true
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
    
    
//    func openDocument(sender: AnyObject) {
//    }
    
}

extension AppDelegate {
    
    
    func urlArraytoStrArray(input: [URL]) -> NSMutableArray {
        let m = [] as NSMutableArray
        input.forEach { url in
            m.add(url.absoluteString)
        }
        return m
    }
    
    func urlStrArraytoUrlArray(input: Array<Any>) -> [URL] {
        var m = [URL]()
        input.forEach { url in
            let u = url as! String
            m.append(URL(string:u)!)
        }
        return m
    }

    
    func readProjectFile(projectFile: String) {
        let path = URL(string: projectFile)
        
        // print("READING PRPOJECT FILE")
        do {
            let data = try Data(contentsOf: path!, options: .alwaysMapped)
            let projectJson = try? JSONSerialization.jsonObject(with: data, options: [])
            
            
            if let dictionary = projectJson as? [String: Any] {
                
                
                // Keep this guy at the top...
                if(dictionary["thumbnailDirectory"] != nil) {
                    self.appSettings.thumbnailDirectory = dictionary["thumbnailDirectory"] as! String
                } else {
                    self.appSettings.thumbnailDirectory = dictionary["projectDirectory"] as! String
                    
                }

                
                
                
                if(dictionary["favoriteUrls"] != nil) {
                    self.appSettings.favoriteUrls = urlStrArraytoUrlArray(input: dictionary["favoriteUrls"] as! Array<Any>)
                    //self.appSettings.favoriteUrls = []

                    self.favoritesCollectionViewController?.reloadContents()

                } else {
                    self.appSettings.favoriteUrls = [URL]()
                    self.favoritesCollectionViewController?.reloadContents()
                }
                
                
                if(dictionary["mediaBinUrls"] != nil) {
                    self.appSettings.mediaBinUrls = urlStrArraytoUrlArray(input: dictionary["mediaBinUrls"] as! Array<Any>)
                    
                    //self.appSettings.mediaBinUrls = []

                    self.screenShotSliderController?.reloadContents()

                } else {
                    self.appSettings.mediaBinUrls = [URL]()
                    self.screenShotSliderController?.reloadContents()
                }
                
                
                if(dictionary["projectName"] != nil) {
                    self.appSettings.fileSequenceName = dictionary["projectName"] as! String
                }
                
                
                if(dictionary["projectDirectory"] != nil) {
                    self.appSettings.projectFolder = dictionary["projectDirectory"] as! String
                }
                
                
                if(dictionary["outputDirectory"] != nil) {
                    self.appSettings.outputDirectory = dictionary["outputDirectory"] as! String
                }
                
                
                if(dictionary["currentDirectory"] != nil) {
                    self.appSettings.folderURL = dictionary["currentDirectory"] as! String
                }
                
                
                if(dictionary["videosDirectory"] != nil) {
                    self.appSettings.videoFolder = dictionary["videosDirectory"] as! String
                }
                
                
                if(dictionary["videoClipsDirectory"] != nil) {
                    self.appSettings.videoClipsFolder = dictionary["videoClipsDirectory"] as! String
                }
                
                if(dictionary["jpgDirectory"] != nil) {
                    self.appSettings.jpgFolder = dictionary["jpgDirectory"] as! String
                }
                
                
                if(dictionary["rawDirectory"] != nil) {
                    self.appSettings.rawFolder = dictionary["rawDirectory"] as! String
                }
                
                if(dictionary["screenShotFolder"] != nil) {
                    self.appSettings.screenShotFolder = dictionary["screenShotFolder"] as! String
                }
                
                
                
                
                if(dictionary["screenshotFramesAfter"] != nil) {
                    self.appSettings.screenshotFramesAfter = dictionary["screenshotFramesAfter"] as! Int32
                }
                
                
                if(dictionary["screenshotFramesBefore"] != nil) {
                    self.appSettings.screenshotFramesBefore = dictionary["screenshotFramesBefore"] as! Int32
                }
                

                if(dictionary["screenshotSound"] != nil) {
                    self.appSettings.screenshotSound = dictionary["screenshotSound"] as! Bool
                }
              
               
                if(dictionary["screenShotBurstEnabled"] != nil) {
                    self.appSettings.screenShotBurstEnabled = dictionary["screenShotBurstEnabled"] as! Bool
                }
                
                
                if(dictionary["screenshotTypeJPG"] != nil) {
                    self.appSettings.screenshotTypeJPG = dictionary["screenshotTypeJPG"] as! Bool
                }
                
            
                if(dictionary["screenshotTypePNG"] != nil) {
                    self.appSettings.screenshotTypePNG = dictionary["screenshotTypePNG"] as! Bool
                }
                
                if(dictionary["screenshotTypePNG"] != nil) {
                    self.appSettings.screenshotTypePNG = dictionary["screenshotTypePNG"] as! Bool
                }

                
                if(dictionary["screenshotPreview"] != nil) {
                    self.appSettings.screenshotPreview = dictionary["screenshotPreview"] as! Bool
                }

                
                if(dictionary["screenshotFramesInterval"] != nil) {
                    self.appSettings.screenshotFramesInterval = dictionary["screenshotFramesInterval"] as! Double
                }

                
                if(dictionary["screenshotPreserveVideoDate"] != nil) {
                    self.appSettings.screenshotPreserveVideoDate = dictionary["screenshotPreserveVideoDate"] as! Bool
                }

                
                if(dictionary["screenshotPreserveVideoLocation"] != nil) {
                    self.appSettings.screenshotPreserveVideoLocation = dictionary["screenshotPreserveVideoLocation"] as! Bool
                }

                
                if(dictionary["screenshotPreserveVideoName"] != nil) {
                    self.appSettings.screenshotPreserveVideoName = dictionary["screenshotPreserveVideoName"] as! Bool
                }
                
                if(dictionary["videoPlayerAlwaysPlay"] != nil) {
                    self.appSettings.videoPlayerAlwaysPlay = dictionary["videoPlayerAlwaysPlay"] as! Bool
                }
                
                if(dictionary["videoPlayerAutoPlay"] != nil) {
                    self.appSettings.videoPlayerAutoPlay = dictionary["videoPlayerAutoPlay"] as! Bool
                }
                
                if(dictionary["videoPlayerLoopAll"] != nil) {
                    self.appSettings.videoPlayerLoopAll = dictionary["videoPlayerLoopAll"] as! Bool
                }
                
                if(dictionary["videoPlayerLoop"] != nil) {
                    self.appSettings.videoPlayerLoop = dictionary["videoPlayerLoop"] as! Bool
                }
                
                
                if(dictionary["videoPlayerLoopAll"] != nil) {
                    self.appSettings.videoPlayerLoopAll = dictionary["videoPlayerLoopAll"] as! Bool
                }
                
                
                if(dictionary["createProjectDirectory"] != nil) {
                    self.appSettings.createProjectDirectory = dictionary["createProjectDirectory"] as! Bool
                }
                
                if(dictionary["createProjectSubDirectories"] != nil) {
                    self.appSettings.createProjectSubDirectories = dictionary["createProjectSubDirectories"] as! Bool
                }
                
                if(dictionary["lastFolderOpened"] != nil) {
                    self.appSettings.lastFolderOpened = dictionary["lastFolderOpened"] as! String
                    
                    self.fileBrowserViewController?.sourceFolderOpened = URL(string: self.appSettings.lastFolderOpened)
                    
                } else {
                    self.fileBrowserViewController?.sourceFolderOpened = URL(string: self.appSettings.projectFolder)
                }
                
                if(dictionary["lastFileOpened"] != nil) {
                    self.appSettings.lastFileOpened = dictionary["lastFileOpened"] as! String
                    self.fileBrowserViewController?.openLastFile()
                }
            
                 self.fileBrowserViewController?.fileSequenceNameTextField.stringValue = self.appSettings.fileSequenceName

            }
            
            self.defaults.setValue(path?.absoluteString, forKey: "lastProjectfileOpened")

            //  print(projectJson!)
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func writeProjectFile (projectPath: String) {
        if(checkFolderAndCreate(folderPath: projectPath)) {
            
            //print("CREATING DRONE FILES PROJECT")
            
            let documentsDirectoryPath = NSURL(string: projectPath)!
            
            let jsonFilePath = documentsDirectoryPath.appendingPathComponent(self.appSettings.fileSequenceName + ".dronefiles")
            
            
            // creating a .json file in the Documents folder
            
            let fileManager = FileManager.default
            
            var isDirectory: ObjCBool = false
            var foo = jsonFilePath?.absoluteString.replacingOccurrences(of: "file://", with: "")
            
            foo = foo?.replacingOccurrences(of: "%20", with: " ")
            
            if !fileManager.fileExists(atPath: (jsonFilePath?.absoluteString)!, isDirectory: &isDirectory) {
                
                let created = fileManager.createFile(atPath: foo!, contents: nil, attributes: nil)
                if created {
                   // print("File created ")
                } else {
                    print("Couldn't create file for some reason")
                }
            } else {
               // print("File already exists")
            }
            
            
            // creating an array of test data

            let dic = NSMutableDictionary()
            
            dic.setValue(urlArraytoStrArray(input: self.appSettings.favoriteUrls), forKey: "favoriteUrls")
            dic.setValue(urlArraytoStrArray(input: self.appSettings.mediaBinUrls), forKey: "mediaBinUrls")
            
            dic.setValue(self.appSettings.fileSequenceName, forKey: "projectName")
            dic.setValue(self.appSettings.projectFolder, forKey: "projectDirectory")
            dic.setValue(self.appSettings.videoFolder, forKey: "videosDirectory")
            dic.setValue(self.appSettings.videoClipsFolder, forKey: "videoClipsDirectory")
            dic.setValue(self.appSettings.jpgFolder, forKey: "jpgDirectory")
            dic.setValue(self.appSettings.rawFolder, forKey: "rawDirectory")
            dic.setValue(self.appSettings.outputDirectory, forKey: "outputDirectory")
            dic.setValue(self.appSettings.thumbnailDirectory, forKey: "thumbnailDirectory")
            
            dic.setValue(self.appSettings.screenshotFramesAfter, forKey: "screenshotFramesAfter")
            dic.setValue(self.appSettings.screenshotFramesBefore, forKey: "screenshotFramesBefore")
            dic.setValue(self.appSettings.screenshotSound, forKey: "screenshotSound")
            dic.setValue(self.appSettings.screenShotFolder, forKey: "screenShotFolder")
            dic.setValue(self.appSettings.screenShotBurstEnabled, forKey: "screenShotBurstEnabled")
            dic.setValue(self.appSettings.screenshotTypeJPG, forKey: "screenshotTypeJPG")
            dic.setValue(self.appSettings.screenshotTypePNG, forKey: "screenshotTypePNG")
            dic.setValue(self.appSettings.screenshotPreview, forKey: "screenshotPreview")
            dic.setValue(self.appSettings.screenshotFramesInterval, forKey: "screenshotFramesInterval")
            dic.setValue(self.appSettings.screenshotPreserveVideoDate, forKey: "screenshotPreserveVideoDate")
            dic.setValue(self.appSettings.screenshotPreserveVideoLocation, forKey: "screenshotPreserveVideoLocation")
            dic.setValue(self.appSettings.screenshotPreserveVideoName, forKey: "screenshotPreserveVideoName")
            dic.setValue(self.appSettings.videoPlayerAlwaysPlay, forKey: "videoPlayerAlwaysPlay")
            dic.setValue(self.appSettings.videoPlayerAutoPlay, forKey: "videoPlayerAutoPlay")
            dic.setValue(self.appSettings.videoPlayerLoopAll, forKey: "videoPlayerLoopAll")
            dic.setValue(self.appSettings.videoPlayerLoop, forKey: "videoPlayerLoop")
            dic.setValue(self.appSettings.createProjectDirectory, forKey: "createProjectDirectory")
            dic.setValue(self.appSettings.createProjectSubDirectories, forKey: "createProjectSubDirectories")
            dic.setValue(self.appSettings.lastFolderOpened, forKey: "lastFolderOpened")
            dic.setValue(self.appSettings.lastFileOpened, forKey: "lastFileOpened")
            dic.setValue(self.appSettings.folderURL, forKey: "currentDirectory")
        
            // print(dic)
            
            // print("Try this Path: \(String(describing: jsonFilePath))")
            
            var jsonData: Data!
            
            do {
                jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
                
                // Write that JSON to the file created earlier
                do {
                    let file = try FileHandle.init(forWritingTo: jsonFilePath!)
                    file.write(jsonData)
                    // print("JSON data was written to the file successfully!")
                    // readProjectFile(projectFile: (jsonFilePath?.absoluteString)!)
                } catch let error as NSError {
                    print("Couldn't write to file: \(error.localizedDescription)")
                }
                
                // print("\(String(describing: jsonString))")
                
            } catch let error as NSError {
                print("Array to JSON conversion failed: \(error.localizedDescription)")
            }
        }
    }

    
    func checkFolderAndCreate(folderPath: String) -> Bool {
        do {
            try FileManager.default.createDirectory(at: URL(string: folderPath)!, withIntermediateDirectories: true, attributes: nil)
            // print("Created Directory... " + folderPath)
            return true
        } catch _ as NSError {
            print("Error while creating a folder.")
            return false
        }
    }
    
}
extension Array {
    mutating func delete(element: String) {
        self = self.filter() { $0 as! String != element }
    }
}

extension NSViewController {
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    var appSettings:AppSettings {
        return appDelegate.appSettings
    }
    
    // Helper Functions
    func urlStringToDisplayURLString(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }
    
    func urlStringToDisplayPath(input: String) -> String {
        return input.replacingOccurrences(of: "file://", with: "").replacingOccurrences(of: "%20", with: " ")
    }

}

extension NSWindowController {
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    var appSettings:AppSettings {
        return appDelegate.appSettings
    }
}


extension NSWindow {
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    var appSettings:AppSettings {
        return appDelegate.appSettings
    }
}


extension NSView {
    
    //var setTranslatesAutoresizingMaskIntoConstraints = false

    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    var appSettings:AppSettings {
        return appDelegate.appSettings
    }
}

extension NSTableHeaderCell {
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    var appSettings:AppSettings {
        return appDelegate.appSettings
    }
}


extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}


extension NSScreen {
    class func externalScreens() -> [NSScreen] {
        guard let screens = NSScreen.screens() else { return [] }
        return screens.filter {
            guard let deviceID = $0.deviceDescription["NSScreenNumber"] as? NSNumber else { return false }
            return CGDisplayIsBuiltin(deviceID.uint32Value) == 0
        }
    }
}
