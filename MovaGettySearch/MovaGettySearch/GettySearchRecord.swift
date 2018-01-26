//
//  GettySearchRecord.swift
//  MovaGettySearch
//
//  Created by Artem Misesin on 1/25/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import UIKit
import RealmSwift

final class GettySearchRecord: Object {
    
    @objc dynamic var searchPhrase = ""
    @objc dynamic var imageData: Data? = nil
    @objc dynamic var dateAdded: Date? = nil
    
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
