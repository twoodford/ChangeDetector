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

class CTDurationFormatter : Formatter {
    let formatter = DateComponentsFormatter()
    
    override init() {
        formatter.unitsStyle = .short
        formatter.allowsFractionalUnits = true
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        formatter.unitsStyle = .short
        formatter.allowsFractionalUnits = true
        super.init(coder: aDecoder)
    }
    
    override func string(for obj: Any?) -> String {
        if let duration = obj as? TimeInterval {
            return formatter.string(from: duration)!
        } else {
            return "()"
        }
    }
}
