//
//  filetypes.swift
//  changetrackd
//
//  Created by Tim on 6/7/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import Cocoa
import ChangeTracking

// : [String:ChangeTracker]
let FILE_TYPES : [String:ChangeTracker.Type] =
                ["home.asterius.file.hash" : FileHashTracker.self,
                 "home.asterius.directory.hash" : DirectoryTracker.self,
                 "home.asterius.photolib.masters" : PhotosLibraryTracker.self,
                 "home.asterius.photolib.mastersandthumbs" : PhotosLibraryThumbsTracker.self]

public func changeTrackerType(forFile url: URL) -> String {
    var isDir: ObjCBool = false
    if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
        return ""
    }
    let fileType = try! NSWorkspace.shared.type(ofFile: url.path)
    print(fileType)
    // Time to have some fun
    if fileType == "com.apple.photos.library" {
        return "home.asterius.photolib.mastersandthumbs"
    } else if isDir.boolValue {
        return "home.asterius.directory.hash"
    } else {
        return "home.asterius.file.hash"
    }
}

public func getTracker(trackerID: String) -> ChangeTracker? {
    if let ctType = FILE_TYPES[trackerID] {
        return ctType.init()
    } else {
        return nil
    }
}

public class PhotosLibraryTracker : ChangeTracker {
    let directoryTracker = DirectoryTracker()
    
    public required init() { }
    
    public func setTrackData(baseURL url: URL, dat: Any) {
        directoryTracker.setTrackData(baseURL: url.appendingPathComponent("Masters"), dat: dat)
    }
    
    public func getTrackData() -> Any {
        return directoryTracker.getTrackData()
    }
    
    public func didChange() -> [ChangeDescription] {
        return directoryTracker.didChange()
    }
}

public class PhotosLibraryThumbsTracker : ChangeTracker {
    let mastersTracker = DirectoryTracker()
    let generatedTracker = DirectoryTracker()
    let thumbsTracker = DirectoryTracker()
    
    public required init() {
        mastersTracker.reportAddedFiles = false
        generatedTracker.reportRemovedFiles = false
        generatedTracker.reportAddedFiles = false
        thumbsTracker.reportRemovedFiles = false
        thumbsTracker.reportAddedFiles = false
    }
    
    public func setTrackData(baseURL url: URL, dat: Any) {
        var dat3: [String:Any] = ["masters":[],
                                  "generated":[],
                                  "thumbs":[]]
        if let dat2 = dat as? [String: Any]{
            dat3 = dat2
        }
        mastersTracker.setTrackData(baseURL: url.appendingPathComponent("Masters"), dat: dat3["masters"]!)
        generatedTracker.setTrackData(baseURL: url.appendingPathComponent("resources/media"), dat: dat3["generated"]!)
        thumbsTracker.setTrackData(baseURL: url.appendingPathComponent("resources/proxies/derivatives"), dat: dat3["thumbs"]!)
    }
    
    public func getTrackData() -> Any {
        return ["masters": mastersTracker.getTrackData(),
                "generated": generatedTracker.getTrackData(),
                "thumbs": thumbsTracker.getTrackData()]
    }
    
    public func didChange() -> [ChangeDescription] {
        var changes = mastersTracker.didChange()
        changes.append(contentsOf: generatedTracker.didChange())
        changes.append(contentsOf: thumbsTracker.didChange())
        return changes
    }
}
