//
//  changetrackdproto.swift
//  changetrackd
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation

@objc(changetrackdproto) public protocol changetrackdproto {
    func setPaths(urls: [String], uuids: [String])
    func getChanges(forUUID: String, handler: ([String],[String])->Void)
    func warm() // Dummy function to get the daemon started
    func update(completionHandler: ()->Void)  // Force an update
}
