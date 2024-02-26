//
//  Resource+Photo.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 24/02/24.
//

import Foundation

extension Resource {
    static func photos(page: Int, limit: Int = 100) -> Resource<Photos> {
        let url = APIConstants.baseURL.appendingPathComponent("/v2/list", conformingTo: .url)
        
        let parameters: [String: CustomStringConvertible] = [
            "page": page,
            "limit": limit
        ]
        return Resource<Photos>(url: url, parameters: parameters)
    }
    
    static func details(id: String) -> Resource<Photo> {
        let url = APIConstants.baseURL.appendingPathComponent("/id/\(id)/info", conformingTo: .url)
        
        return Resource<Photo>(url: url)
    }
}
