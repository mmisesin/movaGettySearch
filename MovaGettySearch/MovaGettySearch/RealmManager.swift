//
//  RealmManager.swift
//  MovaGettySearch
//
//  Created by Artem Misesin on 1/26/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    func getRecords() -> Results<GettySearchRecord>? {
        do {
            let realm = try Realm()
            return realm.objects(GettySearchRecord.self).sorted(byKeyPath: "dateAdded", ascending: false)
        } catch {
            return nil
        }
    }
    
    func addRecord(_ record: GettySearchRecord, completion: @escaping (Result<String?>) -> Void) {
        do {
            let realm = try Realm()
            record.dateAdded = Date()
            try realm.write {
                realm.add(record)
                completion(.success(nil))
            }
        } catch {
                completion(.failure(error))
        }
    }
    
    func deleteRecord(_ record: GettySearchRecord, completion: @escaping (Result<String?>) -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(record)
                completion(.success(nil))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
}
