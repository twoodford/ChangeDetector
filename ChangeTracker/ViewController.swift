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
    
    @IBOutlet var URLTable: NSTableView!;
    
    @objc var appDelegate = NSApplication.shared.delegate! as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appDelegate.URLArrayController = URLArrayController
        appDelegate.URLTable = URLTable
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func test(sender: NSButton) {
        print(URLTable.selectedRow);
        
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
            }
        }
    }
}
