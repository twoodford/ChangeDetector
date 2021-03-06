//
//  changestorage.swift
//  changetrackd
//
//  Created by Tim on 6/24/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Cocoa

// Do not access directly for thread safety reasons
let _change_storage = ChangeStorage(storageURL: STORAGE_FILE_URL.appendingPathComponent("changes.sqlite3"))

public func getChangeStore() -> ChangeStorage {
    return ChangeStorage(parent: _change_storage)
}

public class ChangeStorage {
    let moc: NSManagedObjectContext
    let parent: ChangeStorage?
    init(storageURL: URL) {
        // Mostly copied from Apple's "Making Core Data Your Model Layer" document
        guard let modelURL = Bundle(for: ChangeStorage.self).url(forResource: "detected-changes", withExtension: "momd") else {
            fatalError("failed to find data model")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to create model from file: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        do {
            try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storageURL, options: nil)
        } catch {
            fatalError("Error configuring persistent store: \(error)")
        }
        moc = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        parent = nil
    }
    
    init(parent nparent: ChangeStorage) {
        moc = NSManagedObjectContext(concurrencyType:.privateQueueConcurrencyType)
        // Sorry, confusing: basically, we're setting our MOC's parent to the MOC of
        // the parent ChangeStorage object
        moc.parent = nparent.moc
        self.parent = nparent
    }
    
    // Must be called from inside a perform block
    func _getBaseURL(forUUID uuid: UUID) throws -> BaseURL? {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "BaseURL")
        req.predicate = NSPredicate(format: "uuid == %@", argumentArray: [uuid.uuidString])
        //DBG print(req.predicate!)
        let baseURLs = try moc.fetch(req)
        if baseURLs.count > 1 {
            print(baseURLs.count)
            NSLog("BaseURL error, count=%i", baseURLs.count)
            fatalError("Duplicate BaseURLs")
        } else if baseURLs.count == 0 {
            return nil
        }
        return (baseURLs[0] as! BaseURL)
    }
    
    public func addUUID(_ uuid: UUID) {
        moc.performAndWait {
            let baseURL = BaseURL(context: moc)
            baseURL.uuid = uuid.uuidString
            baseURL.changes = NSOrderedSet()
            moc.insert(baseURL)
            try! moc.save()
        }
        self.commit()
    }
    
    public func getChangeDescriptions(forUUID uuid: UUID) -> [ChangeDescription] {
        let changes = getChanges(forUUID: uuid)
        var ret: [ChangeDescription] = []
        for change in changes {
            ret.append(ChangeDescription(path: change.path!, extraInfo: change.chDescription!))
        }
        return ret
    }
    
    public func getChanges(forUUID uuid: UUID) -> [DetectedChange] {
        var changes: [Any] = []
        moc.performAndWait {
            do {
                let baseURL = try _getBaseURL(forUUID: uuid)
                if baseURL != nil {
                    changes = (baseURL!.value(forKey: "changes") as! NSOrderedSet).array
                }
            } catch {
                fatalError("Couldn't fetch BaseURL")
            }
        }
        return changes as! [DetectedChange]
    }
    
    public func addChange(_ change: ChangeDescription, uuid: UUID) {
        moc.performAndWait {
            do {
                let baseURL = try _getBaseURL(forUUID: uuid)
                let delta = DetectedChange(context: moc)
                delta.chDescription = change.info
                delta.path = change.filePath
                delta.baseURL = baseURL
                delta.detectDate = Date()
                baseURL!.addToChanges(delta)
                moc.insert(delta)
            } catch {
                fatalError("Couldn't add change")
            }
        }
    }
    
    public func removeChange(object obj: DetectedChange) {
        moc.performAndWait {
            obj.baseURL!.removeFromChanges(obj)
            moc.delete(obj)
        }
    }
    
    public func removeBaseURL(_ uuid: UUID) {
        moc.performAndWait {
            do {
                let baseURL = try _getBaseURL(forUUID: uuid)!
                while baseURL.changes!.count > 0 {
                    let delta = baseURL.changes![0] as! DetectedChange
                    baseURL.removeFromChanges(at: 0)
                    moc.delete(delta)
                }
                moc.delete(baseURL)
            } catch {
                fatalError("error while removeing base URL")
            }
        }
    }
    
    public func recordUpdate(uuid: UUID, duration: TimeInterval) {
        moc.performAndWait {
            do {
                let baseURL = try _getBaseURL(forUUID: uuid)!
                baseURL.lastUpdateDuration = duration
                baseURL.lastUpdate = Date()
            } catch {
                print("Warn: failed to update duration")
            }
        }
    }
    
    public func getUpdateTime(uuid: UUID) -> Date? {
        var ret: Date? = nil
        moc.performAndWait {
            do {
                ret = try _getBaseURL(forUUID: uuid)?.lastUpdate
            } catch {
                print("Warn: failed to update duration")
            }
        }
        return ret
    }
    
    public func getUpdateDuration(uuid: UUID) -> TimeInterval {
        var ret: TimeInterval = 0
        moc.performAndWait {
            do {
                if let x = try _getBaseURL(forUUID: uuid)?.lastUpdateDuration {
                    ret = x
                }
            } catch {
                print("Warn: failed to update duration")
            }
        }
        return ret
    }
    
    public func commit() {
        var savedOK = false
        moc.performAndWait() {
            do {
                print(try moc.save())
                savedOK = true
            } catch {
                print("Error saving context: \(error)")
            }
        }
        if !savedOK {
            fatalError()
        }
        if let realParent = parent {
            print("parent")
            realParent.commit()
        }
    }
}
