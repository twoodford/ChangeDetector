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
    
    @objc dynamic var urlLst: [TrackedURL]
    var viewController: ViewController?
    let ddefaults = ChangeDefaults()
    
    override init() {
        try! FileManager.default.createDirectory(at: STORAGE_FILE_URL, withIntermediateDirectories: true, attributes: nil)
        urlLst = ddefaults.getPaths()
        super.init();
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
    
    @objc dynamic var acknowledgeEnabled: Bool {
        get {
            if let ct = viewController?.ChangesTable {
                return ct.numberOfSelectedRows == 1
            } else {
                return false
            }
        }
    }
    
    @IBAction func acknowledgeChange(sender: AnyObject) {
        // Order is important!
        // 1. Get the objects we want
        // 2. Remove the appropriate row from the view
        //    This needs to happen before CoreData takes the object away
        // 3. Remove the row from the model
        let selectedIndex = viewController!.ChangesTable!.selectedRow
        let selectedItem = viewController!.ChangesArrayController!.selectedObjects![selectedIndex] as! DetectedChange
        viewController!.ChangesArrayController.remove(atArrangedObjectIndex: selectedIndex)
        print(selectedItem.path!)
        viewController!.changeStore.removeChange(object: selectedItem)
        viewController!.changeStore.commit()
        //viewController!.refreshChangesTable(URLRow: viewController!.URLTable.selectedRow)
    }
}

