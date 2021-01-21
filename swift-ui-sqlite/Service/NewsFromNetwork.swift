//
//  NewsFromNetwork.swift
//  swift-ui-sqlite
//
//  Created by Alok Subedi on 20/01/2021.
//

import Foundation
import Combine

class NewsFromNetwork{
    var subscription: Set<AnyCancellable> = []
    private let service: NetworkService
    
    init(_ service: NetworkService) {
        self.service = service
    }
    
    func fetch(request: URLRequest, completion: @escaping(Result<NewsResponse,Error>) -> ()) {
        var error: Error?
        service.run(request).receive(on: RunLoop.main)
            .sink { recievedCompletion in
                switch recievedCompletion{
                case let .failure(error):
                    completion(.failure(error))
                case .finished:
                    break
                }
            } receiveValue: { news in
                completion(.success(news))
                
                
            }.store(in: &subscription)
    }
}
