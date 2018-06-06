//
//  xpcconn.swift
//  ChangeTracker
//
//  Created by Tim on 6/5/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

class changetrackdconn {
    // An XPC service
    lazy var _backend: NSXPCConnection = {
        let connection = NSXPCConnection(serviceName: "home.asterius.changetrackd")
        connection.remoteObjectInterface = NSXPCInterface(with: changetrackdproto.self)
        connection.resume()
        return connection
    }()
    
    deinit {
        self._backend.invalidate()
    }
    
    func updateURLs(list: [TrackedURL]) {
        let connection = self._backend.remoteObjectProxyWithErrorHandler {
            (error) in print("remote proxy error: %@", error)
            } as! changetrackdproto
        connection.setPaths(list)
    }
}
