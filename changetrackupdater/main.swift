//
//  main.swift
//  changetrackupdater
//
//  Created by Tim on 7/2/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

// Make sure file exists
try! "".write(to: STORAGE_FILE_URL.appendingPathComponent("updater.lock"), atomically: false, encoding: .utf8)
let fh = try! FileHandle(forWritingTo: STORAGE_FILE_URL.appendingPathComponent("updater.lock"))

let addMode = CommandLine.arguments.count > 1

if !addMode {
    print("normal mode")
    if check_lock_file(fh.fileDescriptor) != 0 {
        NSLog("Exiting due to existing file lock")
        exit(EXIT_SUCCESS) // someone else is already running
    }
    signal(SIGTERM, { (signum) in
        print("terminating")
        try! FileManager.default.removeItem(at: STORAGE_FILE_URL.appendingPathComponent("updater.lock"))
        exit(0)
    })
    signal(SIGINT, { (signum) in
        print("interrupt")
        try! FileManager.default.removeItem(at: STORAGE_FILE_URL.appendingPathComponent("updater.lock"))
        exit(0)
    })
}

let tracker = Tracker()
if addMode {
    let tg_uuid = UUID(uuidString: CommandLine.arguments[1])!
    var url: TrackedURL? = nil
    for t_url in ChangeDefaults().getPaths() {
        if t_url.id == tg_uuid {
            url = t_url
        }
    }
    if let nn_url = url {
        tracker.addPath(path: nn_url)
    } else {
        fatalError("Could not locate URL")
    }
} else {
    tracker.changeCheck()
}

if !addMode {
    unlock_file(fh.fileDescriptor)
    try! FileManager.default.removeItem(at: STORAGE_FILE_URL.appendingPathComponent("updater.lock"))
}
fh.closeFile()
