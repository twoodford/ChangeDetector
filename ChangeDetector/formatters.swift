//
//  formatters.swift
//  ChangeDetector
//
//  Created by Tim on 7/14/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Cocoa

class CTURLFormatter : Formatter {
    override func string(for obj: Any?) -> String {
        if let url = obj as? URL {
            if url.isFileURL {
                return url.path
            } else {
                return url.absoluteString
            }
        }
        return "(URL unavailable)"
    }
}

// Roughly based on http://www.cocoabuilder.com/archive/cocoa/65467-nstableview-and-ellipses-again.html
class CTURLSizeFormatter : CTURLFormatter {
    @IBOutlet var tableCol: NSTableColumn!
    @IBOutlet var table: NSTableView!
    
    override func string(for obj: Any?) -> String {
        if let url = obj as? URL {
            if url.isFileURL {
                print("hi!")
                let cell = tableCol.dataCell as! NSCell
                let tgWidth = cell.titleRect(forBounds: NSRect(x: 0, y: 0, width: tableCol.width, height: table.rowHeight)).width
                let txtattr = [NSAttributedStringKey.font: cell.font!]
                var components = url.pathComponents.count
                while strify(url: url, numComponents: components).size(withAttributes: txtattr).width > tgWidth {
                    print(strify(url: url, numComponents: components))
                    components = components - 1
                }
                return strify(url: url, numComponents: components) as String
            }
        }
        return super.string(for: obj)
    }
    
    func strify(url: URL, numComponents num: Int) -> NSString {
        // Current hueristic: include 1st and last component if possible
        // If we can only have 1, include only the last
        // Otherwise, prioritise later components over ealier ones
        var x="x"
        for i in 1...num {
            x = x+"x"
        }
        return x as NSString
    }
}
