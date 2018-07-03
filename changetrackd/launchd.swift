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
    let fname = "home.asterius.changetrackd.updater.plist"
    let executablePath = getUpdaterPath()
    let inPlistPath = Bundle.main.resourcePath!+"/"+fname
    let plistIn = try String(contentsOfFile: inPlistPath)
    let plistOut = String(format: plistIn, executablePath)
    let dstPath = NSString(string: "~/Library/LaunchAgents/"+fname).expandingTildeInPath
    try plistOut.write(toFile: dstPath, atomically: true, encoding: .utf8)
}
