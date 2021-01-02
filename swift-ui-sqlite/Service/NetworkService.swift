//
//  NetworkService.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/2/21.
//

import Foundation
import Combine


enum ApplicationError: Error {
    case InvalidResponse
}

struct NetworkService {
    
    static let shared: NetworkService = {
        let service = NetworkService()
        return service
    }()
    
    let session: URLSession
    
    
    private init(urlSession: URLSession = .shared) {
        self.session = urlSession
    }
    
    
    func run<T: Decodable>(_ request: URLRequest, model: T.Type) -> AnyPublisher<T, ApplicationError> {
        
        let urlPublisher = session.dataTaskPublisher(for: request)
        
        return urlPublisher.tryMap { (element) -> Data in
            guard let response = element.response as? HTTPURLResponse else {
                throw ApplicationError.InvalidResponse
            }
            
            if response.statusCode == 500 {
                throw ApplicationError.InvalidResponse
            }
            
            if response.statusCode == 404 {
                throw ApplicationError.InvalidResponse
            }
            
            if response.statusCode == 422 {
                throw ApplicationError.InvalidResponse
            }
            
            return element.data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .mapError { error -> ApplicationError in
            if let error = error as? ApplicationError {
                return error
            } else {
                
                print(error)
                
                return ApplicationError.InvalidResponse
            }
        }
        .eraseToAnyPublisher()
    }
}
