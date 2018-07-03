//
//  storage.swift
//  changetrackd
//
//  Created by Tim on 6/24/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation

let CT_SHARED_CONTAINER_ID = "V3585DUGLZ.home.asterius.changetrack"

public let STORAGE_FILE_URL = (FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: CT_SHARED_CONTAINER_ID)?.appendingPathComponent("changetracker"))!
