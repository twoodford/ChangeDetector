//
//  primitives.swift
//  changetrackd
//
//  Created by Tim on 6/6/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Foundation
import ChangeTracking

// https://stackoverflow.com/questions/24099520/commonhmac-in-swift/24411522#24411522
enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = kCCHmacAlgMD5
        case .SHA1:     result = kCCHmacAlgSHA1
        case .SHA224:   result = kCCHmacAlgSHA224
        case .SHA256:   result = kCCHmacAlgSHA256
        case .SHA384:   result = kCCHmacAlgSHA384
        case .SHA512:   result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

let HASH_ALGO = CryptoAlgorithm.SHA1

func hash(data: Data, algorithm: CryptoAlgorithm) -> String {
    return data.withUnsafeBytes { (dataPtr: UnsafePointer<UInt8>)->String in
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CChar>.allocate(capacity: digestLen)
        let keyStr = "".cString(using: String.Encoding.utf8)!
        let keyLen = keyStr.count
        
        CCHmac(algorithm.HMACAlgorithm, keyStr, keyLen, dataPtr, data.count, result)
        
        let digestData = Data(buffer: UnsafeMutableBufferPointer<CChar>(start: result, count: digestLen))
        result.deallocate(capacity: digestLen)
        
        return digestData.base64EncodedString()
    }
}

public protocol ChangeTracker {
    // Require no-args initializer so we can build these on the fly
    init()
    
    // Tracking data should be either Strings or Dictionaries
    func setTrackData(baseURL: URL, dat: Any);
    func getTrackData() -> Any;
    
    // If sandboxed, show already have entered security context
    func didChange() -> [ChangeDescription];
}

// Tracking data: Dict<URL, SHA-1 hash>
public class FilesHashTracker {
    
    let algo: CryptoAlgorithm = HASH_ALGO
    var tracks: [URL: String] = [:]
    
    public func setTrackData(dat: [URL: String]) {
        tracks = dat
    }
    
    public func getTrackData() -> [URL: String] {
        return tracks
    }
    
    public func didChange() -> [ChangeDescription] {
        var changes = [ChangeDescription]()
        for (path, _) in tracks {
            if !checkFile(url: path) {
                changes.append(ChangeDescription(path: path.path, extraInfo: "File hash changed"))
            }
        }
        return changes
    }
    
    public func addPaths(paths: [URL]) {
        for path in paths {
            let _ = checkFile(url: path)
        }
    }
    
    func checkFile(url: URL) -> Bool {
        let prevHash = tracks[url]
        let fdata = try! Data(contentsOf: url, options: Data.ReadingOptions.uncached)
        tracks[url] = hash(data: fdata, algorithm: algo);
        return prevHash == tracks[url]
    }
}

// Tracking data: String (SHA-1 hash)
public class FileHashTracker : FilesHashTracker, ChangeTracker {
    var hash: String = "";
    var url: URL?;
    
    public required override init() { }
    
    public func setTrackData(baseURL: URL, dat: Any) {
        url = baseURL
        super.tracks[baseURL] = dat as? String ?? ""
    }
    
    public func getTrackData() -> Any {
        if let uurl = url {
            return super.tracks[uurl] ?? ""
        } else {
            return ""
        }
    }
}

// Tracking data structure
// Dict<String, String>
// format: path with leading slash: string data for file tracker
public class DirectoryTracker : ChangeTracker {
    var paths: [String: String] = [:];
    var base: URL?;
    let fileTracker = FilesHashTracker()
    
    public required init() { }
    
    public func setTrackData(baseURL: URL, dat: Any) {
        base = baseURL
        // If data is uninitialized, set base URL and everything will be a new file
        if let pathDat = dat as? [String: String] {
            paths = pathDat
        }
    }
    
    public func getTrackData() -> Any {
        return paths
    }
    
    func buildURLDict(baseURL: URL) -> [URL: String] {
        var ret = [URL:String]()
        for (pathStr, datStr) in paths {
            ret[baseURL.appendingPathComponent(pathStr)] = datStr
        }
        return ret
    }
    
    public func didChange() -> [ChangeDescription] {
        if let baseU = base {
            let basePath = baseU.path
            fileTracker.setTrackData(dat: buildURLDict(baseURL: baseU))
            
            // Check for new files
            var newURLs = [URL]()
            for enumPath in try! FileManager.default.subpathsOfDirectory(atPath: basePath) {
                print(enumPath);
                if !paths.keys.contains(enumPath) {
                    var isDir: ObjCBool = false
                    let enumURL = baseU.appendingPathComponent(enumPath)
                    let exists = FileManager.default.fileExists(atPath: enumURL.path, isDirectory: &isDir)
                    if exists && !isDir.boolValue {
                        newURLs.append(baseU.appendingPathComponent(enumPath))
                    }
                }
            }
            fileTracker.addPaths(paths: newURLs)
            
            // Run the file checks
            var fileChanges = fileTracker.didChange()
            
            // Convert URL-based data back to relative paths
            let droppedComponents = baseU.pathComponents.count
            for (subURL, subData) in fileTracker.getTrackData() {
                let pathComponents = subURL.pathComponents[droppedComponents...]
                paths[pathComponents.joined(separator: "/")] = subData
            }
            
            // Combine change sources
            for url in newURLs {
                fileChanges.append(ChangeDescription(path: url.path, extraInfo: "New file"))
            }
            return fileChanges;
        } else {
            print("warn: base URL not initialized");
            return [];
        }
    }
}

