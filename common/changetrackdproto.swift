//
//  changetrackdproto.swift
//  changetrackd
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

@objc(changetrackdproto) protocol changetrackdproto {
    func setPaths(urls: [String], uuids: [String])
    func getChanges(forUUID: String, handler: ([String],[String])->Void)
}
