//
//  changetrackdimpl.swift
//  changetrackd
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

class changetrackdimpl: NSObject, changetrackdproto {
    func setPaths(_ paths: [TrackedURL]) {
        // TODO
        print("TODO Lazy-loading actual implementation ;)")
        for path in paths {
            print(path.urlString())
        }
    }
    
    func getPaths() -> [TrackedURL] {
        // TODO
        print("TODO Lazy-loading actual implementation ;)")
        return []
    }
    
    override init() {
        // TODO
    }
}
