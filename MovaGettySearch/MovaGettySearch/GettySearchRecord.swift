//
//  GettySearchRecord.swift
//  MovaGettySearch
//
//  Created by Artem Misesin on 1/25/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit
import RealmSwift

final class SearchRecordList: Object {
    
    @objc dynamic var id = ""
    let records = List<GettySearchRecord>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

final class GettySearchRecord: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var searchPhrase = ""
    @objc dynamic var imageData: Data? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func downloadData(url: URL) {
        RequestManager.getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            self.imageData = data
        }
    }
    
}

class GettySearchResult: Decodable {
    
    let result_count: Int
    let images: [ImageResult]
    
}

class ImageResult: Decodable {
    
    let id: String
    let title: String
    let display_sizes: [DisplaySizes]
    
}

class DisplaySizes: Decodable {
    
    let is_watermarked: Bool
    let name: String
    let uri: String
    
}
