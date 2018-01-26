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
    
    var realm: Realm!
    
    func getRecords() -> Results<GettySearchRecord> {
        self.realm = try! Realm()
        return self.realm.objects(GettySearchRecord.self)
    }
    
    func addRecord(_ record: GettySearchRecord, completion: @escaping (Result<String?>) -> Void) {
        do {
            try self.realm.write {
                self.realm.add(record)
                completion(.success(nil))
            }
        } catch {
                completion(.failure(error))
        }
    }
    
}
