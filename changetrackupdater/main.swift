//
//  main.swift
//  changetrackupdater
//
//  Created by Tim on 7/2/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

let fh = try! FileHandle(forWritingTo: STORAGE_FILE_URL.appendingPathComponent("updater.lock"))

if check_lock_file(fh.fileDescriptor) != 0 {
    NSLog("Exiting due to existing file lock")
    exit(EXIT_SUCCESS) // someone else is already running
}

let tracker = Tracker()
tracker.changeCheck()

sleep(200)

__osaSendNotification(withText: "testing testing testing")

unlock_file(fh.fileDescriptor)
fh.closeFile()
