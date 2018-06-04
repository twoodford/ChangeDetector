//
//  main.swift
//  changetrackd
//
//  Created by Tim on 6/4/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//


import Foundation

class XPCServiceDelegate : NSObject, NSXPCListenerDelegate {
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: changetrackdproto.self)
        let exportedObject = changetrackdimpl()
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
}


// Create the listener and resume it:
let delegate = XPCServiceDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate;
listener.resume()
