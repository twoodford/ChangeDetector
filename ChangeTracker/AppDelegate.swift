//
//  AppDelegate.swift
//  ChangeTracker
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Cocoa
import ChangeTracking

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @objc dynamic var urlLst = [TrackedURL]()
    var URLArrayController: NSArrayController?
    var URLTable: NSTableView?
    
    override init() {
        super.init();
        urlLst.append(TrackedURL(trackURL: URL(string: "/Users/Shared")!));
        urlLst.append(TrackedURL(trackURL: URL(string: "/Users/Shared")!));
//        let x = TrackedURL(trackURL: URL(string: "/Users/Shared")!)
//        let dat = NSMutableData(length: 256)!
//        let z1 = NSKeyedArchiver(forWritingWith: dat)
//        x.encode(with: z1)
//        let z2 = NSKeyedUnarchiver(forReadingWith: dat as Data)
//        let y = TrackedURL(coder: z2)!
//        print(y.urlStr)
//        print(y.url)
//        print(y.id)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    class func urlList() -> [TrackedURL] {
        let ww = NSApplication.shared.delegate! as! AppDelegate
        return ww.urlLst
    }
}

