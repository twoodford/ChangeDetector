//
//  ViewController.swift
//  ChangeTracker
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var URLArrayController: NSArrayController!;
    
    @IBOutlet var url: NSTableColumn!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("i'm here");
        // Do any additional setup after loading the view.
        URLArrayController.content = AppDelegate.urlList();
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func test(sender: NSButton) {
        print(url.dataCell);
    }
}

class WindowController: NSWindowController {
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    @IBAction func addURL(caller: NSToolbarItem) {
        print("TODO lazy load");
        let ww = NSApplication.shared.delegate! as! AppDelegate
        ww.urlLst.append(TrackedURL(trackURL: URL(string: "/Users/Shared")!));
        for url in ww.urlLst {
            print(url.urlString());
        }
    }
    
    @IBAction func removeURL(caller: NSToolbarItem) {
        print("TODO lazy load");
    }
}
