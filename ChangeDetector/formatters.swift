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
