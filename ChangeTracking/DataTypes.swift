//
//  DataTypes.swift
//  ChangeTracker
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation

public class TrackedURL : NSObject,NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    public var urlStr:String;
    public var url:URL;
    public var id:UUID;
    
    public init(trackURL: URL, uuid: UUID? = nil) {
        url = trackURL;
        urlStr = url.absoluteString;
        if uuid != nil { id = uuid!; }
        else { id = UUID(); }
        super.init()
    }
    
    @objc public func urlString() -> String {
        return urlStr;
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(url as NSURL, forKey: "url")
        coder.encode(id as NSUUID, forKey: "uuid")
    }
    
    required public init?(coder decoder: NSCoder) {
        let uuid = decoder.decodeObject(of: NSUUID.self, forKey: "uuid")!
        let urlIn = decoder.decodeObject(of: NSURL.self, forKey: "url")!
        url = urlIn as URL
        id = uuid as UUID
        urlStr = url.absoluteString;
    }
}
