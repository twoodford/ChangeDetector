//
//  dataextensions.swift
//  ChangeTracking
//
//  Created by Tim on 8/27/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation

extension DetectedChange {
    @objc
    func truncatedPath() -> String {
        let baseUUID = UUID(uuidString: self.baseURL!.uuid!)
        let basePath = ChangeDefaults().getPaths().filter({basep in
            return basep.id == baseUUID
        }).first
        let basePathLen = basePath!.url.path.count
        let str = self.path!
        return String(str[str.index(str.startIndex, offsetBy: basePathLen+1)...])
    }
}
