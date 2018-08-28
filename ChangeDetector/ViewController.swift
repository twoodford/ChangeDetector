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
    @IBOutlet var ChangesTable: NSTableView!;
    @IBOutlet var StatusText: NSTextField!;
    @IBOutlet var ProgressIndicator: NSProgressIndicator!;
    @objc dynamic var changeList: [ChangeDescription] = []
    
    @objc var appDelegate = NSApplication.shared.delegate! as! AppDelegate
    
    let xpcconn = changetrackdconn()
    let changeStore = getChangeStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appDelegate.viewController = self
        
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
        
        refreshChangesTable(URLRow: URLTable.clickedRow)
    }
    
    func refreshChangesTable(URLRow: Int) {
        let selPath = (URLArrayController.arrangedObjects as! [TrackedURL])[URLRow]
        
        let changes = changeStore.getChanges(forUUID: selPath.id)
//        let basePathLen = selPath.url.path.count
        
//        let truncatedCh = changes.map({(dc: DetectedChange) -> (DetectedChange) in
//            let str = dc.path!
//            dc.path = String(str[str.index(str.startIndex, offsetBy: basePathLen+1)...])
//            return dc
//        })
        
        // Clear previous
        let len = (self.ChangesArrayController.arrangedObjects as! [ChangeDescription]).count
        self.ChangesArrayController.remove(atArrangedObjectIndexes: IndexSet(integersIn: 0..<len))
        
        // Add new paths
        self.ChangesArrayController.add(contentsOf: changes)
    }
    
    func statusStartManualUpdate() {
        StatusText.stringValue = "Updating..."
        ProgressIndicator.startAnimation(self)
        ProgressIndicator.isHidden = false
    }
    
    func statusFinishManualUpdate() {
        StatusText.stringValue = "Update Complete"
        ProgressIndicator.stopAnimation(self)
        ProgressIndicator.isHidden = true
    }
    
    func statusStartAddUpdate() {
        StatusText.stringValue = "Adding path..."
        ProgressIndicator.startAnimation(self)
        ProgressIndicator.isHidden = false
    }
    
    func statusFinishAddUpdate() {
        StatusText.stringValue = "Added path"
        ProgressIndicator.stopAnimation(self)
        ProgressIndicator.isHidden = true
    }
}

class WindowController: NSWindowController {
    var appDelegate = NSApplication.shared.delegate! as! AppDelegate
    var xpcconn = changetrackdconn()
    let changeStore = getChangeStore()
    @IBOutlet var refreshButton: NSToolbarItem!
    var enableRefreshButton = true
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    @IBAction func addURL(caller: NSToolbarItem) {
        self.appDelegate.viewController!.statusStartAddUpdate()
        self.refreshButton.isEnabled = false
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.beginSheetModal(for: self.window!, completionHandler: { (result) -> Void in
            if result == NSApplication.ModalResponse.OK {
                let newURL = TrackedURL(trackURL: openPanel.url!)
                self.appDelegate.urlLst.append(newURL);
                getChangeStore().addUUID(newURL.id)
                self.xpcconn.updateURLs(list: self.appDelegate.urlLst, onFinish: {() -> Void in
                    DispatchQueue.main.async {
                        self.appDelegate.viewController!.statusFinishAddUpdate()
                        self.appDelegate.viewController!.URLTable.reloadData()
                        self.refreshButton.isEnabled = true
                    }
                })
            }
        });
    }
    
    @IBAction func removeURL(sender: NSToolbarItem) {
        if let row = appDelegate.viewController?.URLTable?.selectedRow {
            if row >= 0 {
                // Remove tracked changes from the DB
                let tr_urls = appDelegate.viewController?.URLArrayController?.arrangedObjects as! [TrackedURL]
                let uuid = tr_urls[row].id
                changeStore.removeBaseURL(uuid)
                // Tell the tracking backend to remove the URL
                appDelegate.viewController?.URLArrayController?.remove(atArrangedObjectIndex: row)
                self.xpcconn.updateURLs(list: self.appDelegate.urlLst, onFinish: {() -> Void in })
            }
        }
    }
    
    @IBAction func forceUpdate(sender: NSToolbarItem) {
        appDelegate.viewController!.statusStartManualUpdate()
        self.refreshButton.isEnabled = false
        xpcconn.update {
            DispatchQueue.main.async {
                self.appDelegate.viewController!.statusFinishManualUpdate()
                let selRow = self.appDelegate.viewController!.URLTable.selectedRow
                if selRow >= 0 {
                    self.appDelegate.viewController!.refreshChangesTable(URLRow: selRow)
                    self.appDelegate.viewController!.URLTable.reloadData()
                    self.refreshButton.isEnabled = true
                }
            }
        }
    }
}
