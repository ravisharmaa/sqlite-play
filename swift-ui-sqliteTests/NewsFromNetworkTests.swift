//
//  NewsFromNetworkTests.swift
//  swift-ui-sqliteTests
//
//  Created by Alok Subedi on 20/01/2021.
//

import XCTest
import Combine
@testable import swift_ui_sqlite

class NewsFromNetworkTests: XCTestCase {
    func test_init_doesNotRequestDataFromUrl(){
        let service = MockNetworkService()
        let _ = NewsFromNetwork(service)
        
        XCTAssertEqual( service.runCalls, 0)
    }
    
    func test_fetchTwice_requestsDataFromURLTwice() {
        
        let url = URL(string: "https://a-url.com")!
        
        let service = MockNetworkService()
        let sut = NewsFromNetwork(service)
        
        sut.fetch(request: URLRequest(url: url)){ _ in }
        sut.fetch(request: URLRequest(url: url)){ _ in }
        
        XCTAssertEqual( service.runCalls, 2)
    }
    
    func test_load_deliversInvalidDataErrorOnFailure() {
        let url = URL(string: "https://a-url.com")!
        
        let service = MockNetworkService()
        let sut = NewsFromNetwork(service)
        
        service.isValidCase = false
        
        sut.fetch(request: URLRequest(url: url)){ result in
            switch result{
            case let .failure(error):
                if error is ApplicationError{
                    XCTAssertEqual(error as! ApplicationError, ApplicationError.invalidResponse)
                }else {
                    XCTFail("should be ApplicationError")
                }
            default:
                XCTFail("should recieve error")
            }
        }
    }
    
    func test_load_deliversNewsResponseOnSuccess(){
        let url = URL(string: "https://a-url.com")!
        
        let service = MockNetworkService()
        let sut = NewsFromNetwork(service)
        
        service.isValidCase = false
        
        sut.fetch(request: URLRequest(url: url)){ result in
            switch result{
            
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
    }
    
    //MARK: Helpers
    
    class MockNetworkService: NetworkService{
        var runCalls = 0
        var isValidCase = true
        
        override func run(_ request: URLRequest) -> AnyPublisher<NewsResponse, ApplicationError> {
            
            runCalls += 1
            if isValidCase{
                return Just(createNews()).setFailureType(to: ApplicationError.self).eraseToAnyPublisher()
            }else{
                return Fail<NewsResponse, ApplicationError>(error: .invalidResponse).eraseToAnyPublisher()
            }
        }
        
        private func createNews() -> NewsResponse{
            let article = Article(id: "id", name: "name", title: "title", description: "desc", url: "url", urlToImage: "urltoimage", publishedAt: "publishedat", content: "content")
            let articleJson = [
                "id": article.id,
                "name": article.name,
                "title": article.title,
                "description": article.description,
                "url": article.url,
                "urlToImage": article.urlToImage,
                "publishedAt": article.publishedAt,
                "content": article.content
            ]

            let news = NewsResponse(status: "status", totalResults: 2, articles: [article,article])
            let json = [
                "status": news.status,
                "totalResults": news.totalResults,
                "articles": [articleJson,articleJson]
            ] as [String : Any]
            
            return news
        }
    }
    
    
}

