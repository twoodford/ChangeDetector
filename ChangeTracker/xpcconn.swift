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
        var urls: [String] = []
        var uuids: [String] = []
        for track in list {
            urls.append(track.urlStr)
            uuids.append(track.id.uuidString)
        }
        connection.setPaths(urls: urls, uuids: uuids)
    }
    
    func getChanges(forUUID: UUID, handler: ([String],[String])->Void) {
        let connection = self._backend.remoteObjectProxyWithErrorHandler {
            (error) in print("remote proxy error: %@", error)
            } as! changetrackdproto
        connection.getChanges(forUUID: forUUID.uuidString, handler: handler)
    }
}
