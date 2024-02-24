//
//  Photo.swift
//  Digii_Assessment
//
//  Created by Shreyansh Mishra on 24/02/24.
//

import Foundation

struct Photo: Codable {
    let id, author: String
    let width, height: Int
    let url, downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, author, width, height, url
        case downloadURL = "download_url"
    }
}

typealias Photos = [Photo]
