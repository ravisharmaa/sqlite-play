//
//  NetworkService.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/2/21.
//

import Foundation
import Combine

enum ApplicationError: Error {
    case invalidResponse
    case fileNotFound(reason: Error)
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
                throw ApplicationError.invalidResponse
            }
            if response.statusCode == 500 {
                throw ApplicationError.invalidResponse
            }
            if response.statusCode == 404 {
                throw ApplicationError.invalidResponse
            }
            if response.statusCode == 422 {
                throw ApplicationError.invalidResponse
            }
            return element.data
        }
        .decode(type: T.self, decoder: JSONDecoder())
        .mapError { error -> ApplicationError in
            if let error = error as? ApplicationError {
                return error
            } else {
                print(error)
                return ApplicationError.invalidResponse
            }
        }
        .eraseToAnyPublisher()
    }
    
    func download (_ reqeust: URLRequest, completion: @escaping(Result<URL, ApplicationError>) -> Void) {
        
        let task = session.downloadTask(with: reqeust) { (downloadedURL, response, error) in
            
            if let error = error {
                completion(.failure(.fileNotFound(reason: error)))
            }
        
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                completion(.failure(.invalidResponse))
            }
            
            if let downloadedURL = downloadedURL {
                completion(.success(downloadedURL))
            }
            
        }
        
        task.resume()
    }
}
