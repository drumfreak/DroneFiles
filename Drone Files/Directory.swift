import AppKit

public struct Metadata: CustomDebugStringConvertible, Equatable {
    
    let name: String
    let date: Date
    let size: Int64
    let icon: NSImage
    let color: NSColor
    let isFolder: Bool
    let url: URL
    let isFavorite: Bool
    
    init(fileURL: URL, name: String, date: Date, size: Int64, icon: NSImage, isFolder: Bool, color: NSColor, favorite: Bool ) {
        self.name = name
        self.date = date
        self.size = size
        self.icon = icon
        self.color = color
        self.isFolder = isFolder
        self.url = fileURL
        self.isFavorite = favorite
    }
    
    public var debugDescription: String {
        return name + " " + "Folder: \(isFolder)" + " Size: \(size)"
    }
    
}

// MARK:  Metadata  Equatable

public func ==(lhs: Metadata, rhs: Metadata) -> Bool {
    return (lhs.url == rhs.url)
}


public struct Directory  {
    
    var appDelegate:AppDelegate {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    fileprivate var files: [Metadata] = []
    let url: URL
    
    public enum FileOrder: String {
        case Name
        case Date
        case Favorite
        case Size
    }
    
    public init(folderURL: URL) {
        url = folderURL
        var videoUrls = [URL]()
        
        let requiredAttributes = [URLResourceKey.localizedNameKey, URLResourceKey.effectiveIconKey,
                                  URLResourceKey.typeIdentifierKey, URLResourceKey.contentModificationDateKey,
                                  URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey,
                                  URLResourceKey.isPackageKey, URLResourceKey.thumbnailKey]
        if let enumerator = FileManager.default.enumerator(at: folderURL,
                                                           includingPropertiesForKeys: requiredAttributes,
                                                           options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants],
                                                           errorHandler: nil) {
            
            
            // let imageTypes = ["jpg", "JPG", "PNG", "png", "JPEG", "jpeg"]
            
            while let url = enumerator.nextObject() as? URL {
                // print( "\(url )")
                
                do {
                    let properties = try  (url as NSURL).resourceValues(forKeys: requiredAttributes)
                    
                    var icon = NSImage()
                    //
                    //            if(imageTypes.contains(url.pathExtension)) {
                    //
                    //                 icon = NSImage.init(contentsOf: url)!
                    //
                    //            } else {
                    if(properties[URLResourceKey.thumbnailKey] != nil) {
                        icon = properties[URLResourceKey.thumbnailKey] as? NSImage ?? NSImage()
                        // print("This didn't happen")
                        
                    } else if( properties[URLResourceKey.effectiveIconKey] != nil) {
                        icon = properties[URLResourceKey.effectiveIconKey] as? NSImage ?? NSImage()
                        
                       // print("This fucking happen")
                        
                    }
                    //
                    //            }
                    
                    let isFavorite = true
                    
                    files.append(Metadata(fileURL: url,
                                          name: properties[URLResourceKey.localizedNameKey] as? String ?? "",
                                          date: properties[URLResourceKey.contentModificationDateKey] as? Date ?? Date.distantPast,
                                          size: (properties[URLResourceKey.fileSizeKey] as? NSNumber)?.int64Value ?? 0,
                                          icon: icon,
                                          isFolder: (properties[URLResourceKey.isDirectoryKey] as? NSNumber)?.boolValue ?? false,
                                            color: NSColor(),
                                           favorite: isFavorite
                                          ))
                    
                    if(self.appDelegate.isMov(file: url)) {
                      videoUrls.append(url)
                    }

                }
                catch {
                    print("Error reading file attributes")
                }
            }
            
            if(self.appDelegate.project != nil) {
                let videoManager = VideoFileManager()
                videoManager.getVideoFilesForUrls(urls: videoUrls)
            }
            
        }
    }
    
    func getObjects() {
        
    }
    
    func contentsOrderedBy(_ orderedBy: FileOrder, ascending: Bool) -> [Metadata] {
        let sortedFiles: [Metadata]
        switch orderedBy {
        case .Name:
            sortedFiles = files.sorted {
                return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending: ascending,
                                    attributeComparation:itemComparator(lhs:$0.name, rhs: $1.name, ascending:ascending))
            }
        case .Size:
            sortedFiles = files.sorted {
                return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending:ascending,
                                    attributeComparation:itemComparator(lhs:$0.size, rhs: $1.size, ascending: ascending))
            }
        case .Date:
            sortedFiles = files.sorted {
                return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending:ascending,
                                    attributeComparation:itemComparator(lhs:$0.date, rhs: $1.date, ascending:ascending))
            }
            
        case .Favorite:
            sortedFiles = files.sorted {
                return sortMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending: ascending,
                                    attributeComparation:itemComparator(lhs:$0.name, rhs: $1.name, ascending:ascending))
            }
            
            
            
            
        }
        
        
        return sortedFiles
    }
}

// MARK: - Sorting

func sortMetadata(lhsIsFolder: Bool, rhsIsFolder: Bool,  ascending: Bool,
                  attributeComparation: Bool ) -> Bool {
    if( lhsIsFolder && !rhsIsFolder) {
        return ascending ? true : false
    }
    else if ( !lhsIsFolder && rhsIsFolder ) {
        return ascending ? false : true
    }
    return attributeComparation
}

func itemComparator<T:Comparable>( lhs: T, rhs: T, ascending: Bool ) -> Bool {
    return ascending ? (lhs < rhs) : (lhs > rhs)
}


public func ==(lhs: Date, rhs: Date) -> Bool {
    if lhs.compare(rhs) == .orderedSame {
        return true
    }
    return false
}

public func <(lhs: Date, rhs: Date) -> Bool {
    if lhs.compare(rhs) == .orderedAscending {
        return true
    }
    return false
}
