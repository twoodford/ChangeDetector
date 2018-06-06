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
    func setPaths(urls: [String], uuids: [String]) {
        var i=0;
        var tracks: [TrackedURL] = []
        while(i<urls.count) {
            let url = URL(string: urls[i])!
            let uuid = UUID(uuidString: uuids[i])!
            tracks.append(TrackedURL(trackURL: url, uuid: uuid))
            i+=1
        }
        setPaths(tracks)
    }
    
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
