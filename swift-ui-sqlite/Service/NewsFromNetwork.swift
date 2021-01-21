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
    
    var urlComponents: URLComponents  {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "newsapi.org"
        return component
    }
    
    init(_ service: NetworkService = NetworkService(), subscription: Set<AnyCancellable>) {
        self.service = service
        self.subscription = subscription
    }
    
    func fetch(request: URLRequest?, completion: @escaping(Result<NewsResponse,Error>) -> ()) {
        var urlRequest: URLRequest
        if request == nil { urlRequest = URLRequest(url: urlFromURLComponents())}
        else { urlRequest = request!}
        service.run(urlRequest).receive(on: RunLoop.main)
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
    
    func urlFromURLComponents() -> URL{
        var innerUrl = urlComponents
        
        innerUrl.path = "/v2/top-headlines"
        
        var urlQueryItem: [URLQueryItem] = []
        
        let queryItems: [String: String]  = [
            "country": "in",
            "category": "business",
            "apiKey": "721e810f5e984c8b8529b6816ad464b4"
        ]
        
        for (key, data) in queryItems  {
            urlQueryItem.append(.init(name:key, value: data))
        }
        
        innerUrl.queryItems = urlQueryItem
        
        return innerUrl.url!
    }
}
