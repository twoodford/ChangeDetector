//
//  tracker.swift
//  changetrackd
//
//  Created by Tim on 6/7/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

func __osaSendNotification(withText text: String) {
    //    print("testing")
    //    if let osaObj = NSAppleScript(source: "display notification \""+text+"\" with title \"ChangeDetector\"") {
    //        var error: NSDictionary?
    //        osaObj.executeAndReturnError(&error)
    //        if error != nil {
    //            print("OSAScript error: ", error)
    //        }
    //    } else {
    //        print("syntax error")
    //    }
    let task = Process()
    task.launchPath="/usr/bin/osascript"
    task.arguments = ["-e", "display notification \""+text+"\" with title \"ChangeDetector\""]
    task.launch()
    task.waitUntilExit()
}

class Tracker {
    var changes : [UUID: [ChangeDescription]] = [:]
    var delay = 30 // TODO better delay control (1 hour)
    let defaults = ChangeDefaults()
    
    public init() {
        try! FileManager.default.createDirectory(at: STORAGE_FILE_URL, withIntermediateDirectories: true)
        let paths = defaults.getPaths()
        let changeStore = getChangeStore()
        for path in paths {
            changes[path.id] = changeStore.getChangeDescriptions(forUUID: path.id)
        }
    }
    
    public func scheduleUpdater(delaySeconds: Int) {
        let dispatcher = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        let deadline = DispatchTime.now() + .seconds(delaySeconds)
        dispatcher.asyncAfter(deadline: deadline, execute: {
            self.changeCheck()
        })
    }
    
    func filePath(forUUID uuid: UUID) -> URL {
        return STORAGE_FILE_URL.appendingPathComponent(uuid.uuidString)
    }
    
    func trackerData(tracker: ChangeTracker, trackerType: String) -> Data {
        let encData = ["tracker": trackerType,
                       "data": tracker.getTrackData()]
        return try! JSONSerialization.data(withJSONObject: encData, options: [])
    }
    
    func addPath(path: TrackedURL) {
        let datURL = self.filePath(forUUID: path.id)
        let trackerType = changeTrackerType(forFile: path.url)
        let tracker = getTracker(trackerID: trackerType)!
        tracker.setTrackData(baseURL: path.url, dat: [])
        let _ = tracker.didChange()
        try! self.trackerData(tracker: tracker, trackerType: trackerType).write(to: datURL)
    }
    
    func sendChangeNotification() {
        //        let nreq = NSUserNotification()
        //        nreq.informativeText = "New file changes detected"
        //        NSUserNotificationCenter.default.deliver(nreq)
        __osaSendNotification(withText: "New file changes detected")
    }
    
    func _storeChanges(uuid: UUID, addChanges: [ChangeDescription]) {
        changes[uuid]!.append(contentsOf: addChanges)
        let changeStore = getChangeStore()
        for addChange in addChanges {
            changeStore.addChange(addChange, uuid: uuid)
        }
        changeStore.commit()
    }
    
    func changeCheck() {
        var newChanges = false
        let paths = defaults.getPaths()
        for path in paths {
            let addChanges = changeCheck(path: path)
            newChanges = newChanges || addChanges
        }
        if newChanges {
            sendChangeNotification()
        }
    }
    
    func changeCheck(path: TrackedURL) -> Bool {
        var newChanges = false
        let trackDataURL = filePath(forUUID: path.id)
        if changes[path.id] == nil { changes[path.id] = [] }
        // Decode change checking data
        if let decodedDat = try? JSONSerialization.jsonObject(with: Data(contentsOf: trackDataURL), options: []) as! [String:Any]{
            if let trackerType = decodedDat["tracker"] as? String {
                let tracker = getTracker(trackerID: trackerType)!
                tracker.setTrackData(baseURL: path.url, dat: decodedDat["data"]!)
                let addChanges = tracker.didChange()
                _storeChanges(uuid: path.id, addChanges: addChanges)
                if addChanges.count > 0 {
                    newChanges = true
                }
                try! trackerData(tracker: tracker, trackerType: trackerType).write(to: trackDataURL)
            } else {
                print("error: could not find tracker class")
            }
        } else {
            addPath(path: path)
        }
        return newChanges
    }
}
