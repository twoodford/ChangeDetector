//
//  changetrackdimpl.swift
//  changetrackd
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

class changetrackdimpl: NSObject, changetrackdproto {
    
    let ddefaults = ChangeDefaults()
    //    let tracker = Tracker()
    
    override init() {
        super.init()
        //        tracker.scheduleUpdater(delaySeconds: 4)
    }
    
    func setPaths(urls: [String], uuids: [String], onFinish: ()->Void) {
        var i=0;
        var tracks: [TrackedURL] = []
        while(i<urls.count) {
            let url = URL(string: urls[i])!
            let uuid = UUID(uuidString: uuids[i])!
            tracks.append(TrackedURL(trackURL: url, uuid: uuid))
            i+=1
        }
        setPaths(tracks)
        onFinish()
    }
    
    func setPaths(_ paths: [TrackedURL]) {
        let prevPaths = ddefaults.getPaths()
        ddefaults.setPaths(paths);
        for path in paths {
            print(path.urlString())
            if !prevPaths.contains { element in return path.isEqual(to: element) } {
                print("added")
                let proc = Process()
                proc.launchPath = getUpdaterPath()
                proc.arguments = [ path.id.uuidString ]
                proc.launch()
                proc.waitUntilExit()
            }
        }
        for path in prevPaths {
            if !paths.contains { element in return path.isEqual(to: element) } {
                do {
                    try FileManager.default.removeItem(at: STORAGE_FILE_URL.appendingPathComponent(path.id.uuidString))
                    print("removed", path.urlStr)
                } catch {
                    // File probably doesn't exist
                }
            }
        }
    }
    
    func getChanges(forUUID: String, handler: ([String],[String])->Void) {
        let changes = getChangeStore().getChangeDescriptions(forUUID: UUID(uuidString: forUUID)!)
        let paths = changes.map({(cdescription) in
            return cdescription.filePath
        })
        let descriptions = changes.map({(cdescription) in return cdescription.info})
        handler(paths, descriptions)
    }
    
    func warm() {
        NSLog("daemon force-started")
    }
    
    func update(completionHandler: @escaping ()->Void)  {
        let dispatcher = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        dispatcher.async {
            let proc = Process()
            proc.launchPath = getUpdaterPath()
            proc.launch()
            proc.waitUntilExit()
            completionHandler()
        }
    }
}
