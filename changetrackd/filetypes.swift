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
                 "home.asterius.photolib.masters" : PhotosLibraryTracker.self]

public func changeTrackerType(forFile url: URL) -> String {
    var isDir: ObjCBool = false
    if !FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) {
        return ""
    }
    let fileType = try! NSWorkspace.shared.type(ofFile: url.path)
    print(fileType)
    // Time to have some fun
    if isDir.boolValue {
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
