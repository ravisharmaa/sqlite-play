//
//  NewsResponse.swift
//  swift-ui-sqlite
//
//  Created by Alok Subedi on 20/01/2021.
//

import Foundation

struct NewsResponse: Decodable, Hashable {
    
    let status: String
    let totalResults: Int
    
    let articles: [Article]
}
