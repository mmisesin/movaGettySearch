//
//  RequestBuilder.swift
//  MovaGettySearch
//
//  Created by Artem Misesin on 1/25/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import Foundation

struct APIConstants {
    
    static let URLScheme = "https"
    static let URLHost = "api.gettyimages.com"
    
}

enum RequestType {
    
    case search(sortMethod: String, searchWord: String)
    
    var queryItems: [URLQueryItem] {
        let sortKey = "sort_order"
        let searchWordKey = "phrase"
        let fieldsKey = "fields"
        let items = [URLQueryItem(name: fieldsKey, value: "id,title,thumb")]
        switch self {
        case .search(let sortMethod, let searchPhrase):
            return items + [URLQueryItem(name: sortKey, value: sortMethod), URLQueryItem(name: searchWordKey, value: searchPhrase)]
        }
    }
    
    var path: String {
        switch self {
        default: return "/v3/search/images"
        }
    }
    
    var method: String {
        switch self {
        default: return "GET"
        }
    }
    
    var headers: [String: String] {
        switch self {
        default: return [
                         "Api-Key": "guxndurt36ye4h9jfuh2g6ym"]
        }
    }
    
}



