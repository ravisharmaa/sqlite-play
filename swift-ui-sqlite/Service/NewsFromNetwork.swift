//
//  NewsFromNetwork.swift
//  swift-ui-sqlite
//
//  Created by Alok Subedi on 20/01/2021.
//

import Foundation

class NewsFromNetwork{
    private let service: NetworkService
    
    init(_ service: NetworkService) {
        self.service = service
    }
    
    func fetch(request: URLRequest, completion: @escaping() -> ()) {
        service.run(request)
    }
}
