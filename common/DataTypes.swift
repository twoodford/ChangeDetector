//
//  DataTypes.swift
//  ChangeTracker
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation

class TrackedURL : NSObject {
    var urlStr:String;
    var url:URL;
    var id:UUID;
    
    init(trackURL: URL, uuid: UUID? = nil) {
        url = trackURL;
        urlStr = url.absoluteString;
        if uuid != nil { id = uuid!; }
        else { id = UUID(); }
        super.init()
    }
    
    @objc func urlString() -> String {
        return urlStr;
    }
}
