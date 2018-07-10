//
//  ViewController.swift
//  ChangeTracker
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Cocoa
import ChangeTracking

class ViewController: NSViewController {
    
    @IBOutlet var URLArrayController: NSArrayController!;
    @IBOutlet var ChangesArrayController: NSArrayController!;
    @IBOutlet var URLTable: NSTableView!;
    @objc dynamic var changeList: [ChangeDescription] = []
    
    @objc var appDelegate = NSApplication.shared.delegate! as! AppDelegate
    
    let xpcconn = changetrackdconn()
    let changeStore = getChangeStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appDelegate.URLArrayController = URLArrayController
        appDelegate.URLTable = URLTable
        
        xpcconn.warm() // warm up xpc
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func newURLSelected(sender: AnyObject) {
        // Figure out which UUID we want
        if URLTable.clickedRow < 0 {
            return // Nothing's actually selected
        }
        
        let selPath = (URLArrayController.arrangedObjects as! [TrackedURL])[URLTable.clickedRow]
        
        let changes = changeStore.getChanges(forUUID: selPath.id)
        
        // Clear previous
        let len = (self.ChangesArrayController.arrangedObjects as! [ChangeDescription]).count
        self.ChangesArrayController.remove(atArrangedObjectIndexes: IndexSet(integersIn: 0..<len))
        
        // Add new paths
        self.ChangesArrayController.add(contentsOf: changes)
        
    }
}

class WindowController: NSWindowController {
    var appDelegate = NSApplication.shared.delegate! as! AppDelegate
    var xpcconn = changetrackdconn()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    @IBAction func addURL(caller: NSToolbarItem) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.beginSheetModal(for: self.window!, completionHandler: { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
                self.appDelegate.urlLst.append(TrackedURL(trackURL: openPanel.url!));
                self.xpcconn.updateURLs(list: self.appDelegate.urlLst)
            }
        });
    }
    
    @IBAction func removeURL(sender: NSToolbarItem) {
        if let row = appDelegate.URLTable?.selectedRow {
            if row >= 0 {
                appDelegate.URLArrayController?.remove(atArrangedObjectIndex: row)
                self.xpcconn.updateURLs(list: self.appDelegate.urlLst)
            }
        }
    }
    
    @IBAction func forceUpdate(sender: NSToolbarItem) {
        xpcconn.update {
            // nothing for now
        }
    }
}
