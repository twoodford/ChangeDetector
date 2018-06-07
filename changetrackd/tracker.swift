//
//  tracker.swift
//  changetrackd
//
//  Created by Tim on 6/7/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

let CT_SHARED_CONTAINER_ID = "V3585DUGLZ.home.asterius.changetrack"

class Tracker {
    let storageFileURL : URL
    var changes : [ChangeDescription] = []
    var delay = 360 // TODO better delay control (1 hour)
    let defaults = ChangeDefaults()
    
    public init() {
        storageFileURL = (FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CT_SHARED_CONTAINER_ID)?.appendingPathComponent("changetracker"))!
        try! FileManager.default.createDirectory(at: storageFileURL, withIntermediateDirectories: true)
    }
    
    public func scheduleUpdater(delaySeconds: Int) {
        let dispatcher = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        let deadline = DispatchTime.now() + .seconds(delaySeconds)
        dispatcher.asyncAfter(deadline: deadline, execute: {
            self.changeCheck()
        })
    }
    
    func filePath(forUUID uuid: UUID) -> URL {
        return storageFileURL.appendingPathComponent(uuid.uuidString)
    }
    
    func trackerData(tracker: ChangeTracker, trackerType: String) -> Data {
        let encData = ["tracker": trackerType,
                       "data": tracker.getTrackData()]
        return try! JSONSerialization.data(withJSONObject: encData, options: [])
    }
    
    func addPath(path: TrackedURL) {
        let dispatcher = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        dispatcher.async {
            let datURL = self.filePath(forUUID: path.id)
            let trackerType = changeTrackerType(forFile: path.url)
            let tracker = getTracker(trackerID: trackerType)!
            tracker.setTrackData(baseURL: path.url, dat: [])
            let _ = tracker.didChange()
            try! self.trackerData(tracker: tracker, trackerType: trackerType).write(to: datURL)
        }
    }
    
    func changeCheck() {
        let paths = defaults.getPaths()
        for path in paths {
            let url = filePath(forUUID: path.id)
            // Decode change checking data
            if let decodedDat = try? JSONSerialization.jsonObject(with: Data(contentsOf: url), options: []) as! [String:Any]{
                
                if let trackerType = decodedDat["tracker"] as? String {
                    let tracker = getTracker(trackerID: trackerType)!
                    tracker.setTrackData(baseURL: path.url, dat: decodedDat["data"]!)
                    changes.append(contentsOf: tracker.didChange())
                    try! trackerData(tracker: tracker, trackerType: trackerType).write(to: url)
                } else {
                    print("error: could not find tracker class")
                }
            } else {
                addPath(path: path)
            }
        }
        scheduleUpdater(delaySeconds: 360)
    }
}
