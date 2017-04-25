import AppKit

public struct FileListMetadata: CustomDebugStringConvertible, Equatable {
    
    let name: String
    let date: Date
    let size: Int64
    let icon: NSImage
    let color: NSColor
    let isFolder: Bool
    let url: URL
    
    init(fileURL: URL, name: String, date: Date, size: Int64, icon: NSImage, isFolder: Bool, color: NSColor ) {
        self.name = name
        self.date = date
        self.size = size
        self.icon = icon
        self.color = color
        self.isFolder = isFolder
        self.url = fileURL
    }
    
    public var debugDescription: String {
        return name + " " + "Folder: \(isFolder)" + " Size: \(size)"
    }
    
}

// MARK:  Metadata  Equatable

public func ==(lhs: FileListMetadata, rhs: FileListMetadata) -> Bool {
    return (lhs.url == rhs.url)
}


public struct FileManagerList  {
    
    fileprivate var files: [FileListMetadata] = []
    // let url: URL
    let fileList: Array<Any>!
    
    public enum FileOrder: String {
        case Name
        case Date
        case Size
    }
    
    public init(fileArray: AnyObject) {
        fileList = fileArray as! NSMutableArray as! Array<Any>
        let requiredAttributes = [URLResourceKey.localizedNameKey, URLResourceKey.effectiveIconKey,
                                  URLResourceKey.typeIdentifierKey, URLResourceKey.contentModificationDateKey,
                                  URLResourceKey.fileSizeKey, URLResourceKey.isDirectoryKey,
                                  URLResourceKey.isPackageKey]
        
        
        fileList.forEach {
            thisPath in
            // print( "\(url )")
            let thisURL = (thisPath as! NSURL)
            
            do {
                let properties = try thisURL.resourceValues(forKeys: requiredAttributes)
                files.append(FileListMetadata(fileURL: (thisURL as URL!),
                                              name: properties[URLResourceKey.localizedNameKey] as? String ?? "",
                                              date: properties[URLResourceKey.contentModificationDateKey] as? Date ?? Date.distantPast,
                                              size: (properties[URLResourceKey.fileSizeKey] as? NSNumber)?.int64Value ?? 0,
                                              icon: properties[URLResourceKey.effectiveIconKey] as? NSImage  ?? NSImage(),
                                              isFolder: (properties[URLResourceKey.isDirectoryKey] as? NSNumber)?.boolValue ?? false,
                                              color: NSColor()))
            } catch {
                print("Error reading file attributes")
            }
        }
    }
    
    func contentsOrderedBy(_ orderedBy: FileOrder, ascending: Bool) -> [FileListMetadata] {
        let sortedFiles: [FileListMetadata]
        switch orderedBy {
        case .Name:
            sortedFiles = files.sorted {
                return sortFileListMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending: ascending,
                                            attributeComparation:fileListItemComparator(lhs:$0.name, rhs: $1.name, ascending:ascending))
            }
        case .Size:
            sortedFiles = files.sorted {
                return sortFileListMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending:ascending,
                                            attributeComparation:fileListItemComparator(lhs:$0.size, rhs: $1.size, ascending: ascending))
            }
        case .Date:
            sortedFiles = files.sorted {
                return sortFileListMetadata(lhsIsFolder:true, rhsIsFolder: true, ascending:ascending,
                                            attributeComparation:fileListItemComparator(lhs:$0.date, rhs: $1.date, ascending:ascending))
            }
        }
        return sortedFiles
    }
    
}

// MARK: - Sorting

func sortFileListMetadata(lhsIsFolder: Bool, rhsIsFolder: Bool,  ascending: Bool,
                          attributeComparation: Bool ) -> Bool {
    if( lhsIsFolder && !rhsIsFolder) {
        return ascending ? true : false
    }
    else if ( !lhsIsFolder && rhsIsFolder ) {
        return ascending ? false : true
    }
    return attributeComparation
}

func fileListItemComparator<T:Comparable>( lhs: T, rhs: T, ascending: Bool ) -> Bool {
    return ascending ? (lhs < rhs) : (lhs > rhs)
}

