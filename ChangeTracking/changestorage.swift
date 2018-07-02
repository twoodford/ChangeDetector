//
//  changestorage.swift
//  changetrackd
//
//  Created by Tim on 6/24/18.
//  Copyright © 2018 Tim Woodford. All rights reserved.
//

import Cocoa
import ChangeTracking

// Do not access directly for thread safety reasons
let _change_storage = ChangeStorage(storageURL: STORAGE_FILE_URL.appendingPathComponent("changes.sqlite3"))

func getChangeStore() -> ChangeStorage {
    return ChangeStorage(parent: _change_storage)
}

class ChangeStorage {
    let moc: NSManagedObjectContext
    let parent: ChangeStorage?
    init(storageURL: URL) {
        // Mostly copied from Apple's "Making Core Data Your Model Layer" document
        guard let modelURL = Bundle.main.url(forResource: "detected-changes", withExtension: "momd") else {
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
        print(req.predicate!)
        let baseURLs = try moc.fetch(req)
        if baseURLs.count > 1 {
            print(baseURLs.count)
            NSLog("BaseURL error, count=%i", baseURLs.count)
            fatalError("Couldn't fetch BaseURL")
        } else if baseURLs.count == 0 {
            print("add uuid")
            print(uuid)
            _addUUID(uuid)
            return nil
        }
        return (baseURLs[0] as! BaseURL)
    }
    
    // Must be called from inside a perform block
    func _addUUID(_ uuid: UUID) -> BaseURL {
        let baseURL = BaseURL(context: moc)
        baseURL.uuid = uuid.uuidString
        baseURL.changes = NSOrderedSet()
        moc.insert(baseURL)
        try! moc.save()
        return baseURL
    }
    
    public func getChanges(forUUID uuid: UUID) -> [ChangeDescription] {
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
        var ret: [ChangeDescription] = []
        for change in changes {
            let chObj = change as! DetectedChange
            ret.append(ChangeDescription(path: chObj.path!.absoluteString, extraInfo: chObj.chDescription!))
        }
        return ret
    }
    
    public func addChange(_ change: ChangeDescription, uuid: UUID) {
        moc.performAndWait {
            do {
                let baseURL = try _getBaseURL(forUUID: uuid)
                let delta = DetectedChange(context: moc)
                delta.chDescription = change.info
                delta.path = URL(fileURLWithPath: change.filePath)
                delta.baseURL = baseURL
                baseURL!.addToChanges(delta)
                moc.insert(delta)
            } catch {
                fatalError("Couldn't add change")
            }
        }
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
