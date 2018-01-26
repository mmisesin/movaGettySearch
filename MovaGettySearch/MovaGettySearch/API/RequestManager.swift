//
//  RequestManager.swift
//  MovaGettySearch
//
//  Created by Artem Misesin on 1/25/18.
//  Copyright © 2018 misesin. All rights reserved.
//

import Foundation

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

class RequestManager {
    
    static func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    static func sendRequest(of type: RequestType, completion: @escaping (Result<GettySearchResult>) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = APIConstants.URLScheme
        urlComponents.host = APIConstants.URLHost
        urlComponents.path = type.path
        urlComponents.queryItems = type.queryItems
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = type.headers
        request.httpMethod = type.method
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(.failure(error!))
                    return
                }
                
                guard let jsonData = data else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "No data from request"]) as Error
                    completion(.failure(error))
                    return
                }
                
                let decoder = JSONDecoder()
                
                do {
                    let results = try decoder.decode(GettySearchResult.self, from: jsonData)
                    completion(.success(results))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
}
