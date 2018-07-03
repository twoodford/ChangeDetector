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
    
    func setPaths(urls: [String], uuids: [String]) {
        var i=0;
        var tracks: [TrackedURL] = []
        while(i<urls.count) {
            let url = URL(string: urls[i])!
            let uuid = UUID(uuidString: uuids[i])!
            tracks.append(TrackedURL(trackURL: url, uuid: uuid))
            i+=1
        }
        setPaths(tracks)
    }
    
    func setPaths(_ paths: [TrackedURL]) {
//        let prevPaths = ddefaults.getPaths()
//        for path in paths {
//            print(path.urlString())
//            if !prevPaths.contains { element in return path.isEqual(to: element) } {
//                print("added")
//                tracker.addPath(path: path)
//            }
//        }
        ddefaults.setPaths(paths);
    }
    
    func getChanges(forUUID: String, handler: ([String],[String])->Void) {
        let changes = getChangeStore().getChanges(forUUID: UUID(uuidString: forUUID)!)
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
//            proc.launchPath = "/bin/launchctl"
//            proc.arguments = ["start", "home.asterius.changetrackd.updater"]
            proc.launchPath = getUpdaterPath()
            proc.launch()
            proc.waitUntilExit()
            completionHandler()
        }
    }
}
