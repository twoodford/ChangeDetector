//
//  launchd.swift
//  changetrackd
//
//  Created by Tim on 7/2/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Cocoa

func getUpdaterPath() -> String {
    return Bundle.main.resourcePath!+"/changetrackupdater"
}

func writeLaunchdFile() throws {
    print("writing")
    let fname = "home.asterius.changetrackd.updater.plist"
    let executablePath = getUpdaterPath()
    let inPlistPath = Bundle.main.resourcePath!+"/"+fname
    let plist = NSMutableDictionary(contentsOf: URL(fileURLWithPath: inPlistPath))!
    let dstPath = NSString(string: "~/Library/LaunchAgents/"+fname).expandingTildeInPath
    plist.setValue([executablePath], forKey: "ProgramArguments")
    let defaults = UserDefaults()
    var schDict : [String:Int] = [:]
    if defaults.bool(forKey: "sch_weekDayEnabled") {
        schDict["Weekday"] = defaults.integer(forKey: "sch_weekDay")
    }
    if defaults.bool(forKey: "sch_hourEnabled") {
        schDict["Hour"] = defaults.integer(forKey: "sch_hour")
    }
    plist.setValue(schDict, forKey: "StartCalendarInterval")
    plist.write(toFile: dstPath, atomically: true)
}

func backgroundWriteLaunchd() {
    let dispatcher = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    dispatcher.async {
        do {
            try writeLaunchdFile()
        } catch {
            print("couldn't write launchd file")
        }
    }
}

class PreferencesViewController : NSViewController {
    
    override func viewDidLoad() {
        // TODO?
    }
    
    override func viewWillDisappear() {
        try! writeLaunchdFile()
    }
}
