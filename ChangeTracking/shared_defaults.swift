//
//  shared_defaults.swift
//  ChangeTracking framework
//
//  Created by Tim on 6/6/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation

public class ChangeDefaults {
    let userDefaults = UserDefaults(suiteName: "V3585DUGLZ.home.asterius.changetrack")!
    
    public init() {
    }
    
    public func setPaths(_ paths: [TrackedURL]) {
        var pathDefault: Dictionary<String, Data> = [:];
        for path in paths {
            pathDefault[path.id.uuidString] = try! path.url.bookmarkData(options: URL.BookmarkCreationOptions.withSecurityScope)
        }
        userDefaults.set(pathDefault, forKey: "trackedPaths")
    }
    
    public func getPaths() -> [TrackedURL] {
        if let pathDefault = userDefaults.dictionary(forKey: "trackedPaths") as? [String: Data] {
            var paths = [TrackedURL]();
            for (uuidstr, bookmark) in pathDefault {
                let uuid = UUID(uuidString: uuidstr)!
                var isStale: Bool = false
                do {
                    let url = try URL(resolvingBookmarkData: bookmark, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
                    //URL.BookmarkResolutionOptions.withSecurityScope
                    paths.append(TrackedURL(trackURL: url!, uuid: uuid))
                } catch {
                    // Send notification
                    let notif = NSUserNotification()
                    notif.title = "ChangeDetector Error"
                    notif.informativeText = "One of the tracked URLs disappeared"
                    NSUserNotificationCenter.default.deliver(notif)
                    print("Missing URL", uuidstr)
                    // Make it so the user can manually remove item??
                    //paths.append(TrackedURL()
                }
            }
            return paths
        } else {
            return []
        }
    }
}
