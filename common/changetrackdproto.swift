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
    func setPaths(_: [TrackedURL]);
    func getPaths() -> [TrackedURL];
}
