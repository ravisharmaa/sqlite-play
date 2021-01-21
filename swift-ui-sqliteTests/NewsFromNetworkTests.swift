//
//  NewsFromNetworkTests.swift
//  swift-ui-sqliteTests
//
//  Created by Alok Subedi on 20/01/2021.
//

import XCTest
import Combine
@testable import swift_ui_sqlite

class NewsNetorkService: NetworkService{
    
}

class NewsFromNetworkTests: XCTestCase {
    func test_init_doesNotRequestDataFromUrl(){
        let subscription: Set<AnyCancellable> = []
        let service = MockNetworkService()
        let _ = NewsFromNetwork(service, subscription: subscription)
        
        XCTAssertEqual( service.runCalls, 0)
    }
    
    func test_fetchTwice_requestsDataFromURLTwice() {
        
        let url = URL(string: "https://a-url.com")!
        
        let subscription: Set<AnyCancellable> = []
        let service = MockNetworkService()
        let sut = NewsFromNetwork(service, subscription: subscription)
        
        service.news = createNews()
        
        sut.fetch(request: URLRequest(url: url)){ _ in }
        sut.fetch(request: URLRequest(url: url)){ _ in }
        
        XCTAssertEqual( service.runCalls, 2)
    }
    
    func test_load_deliversInvalidDataErrorOnFailure() {
        let url = URL(string: "https://a-url.com")!
        
        let subscription: Set<AnyCancellable> = []
        let service = MockNetworkService()
        let sut = NewsFromNetwork(service, subscription: subscription)
        
        service.isValidCase = false
        
        let exp = expectation(description: "Wait for load completion")
        
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
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    func test_load_deliversNewsResponseOnSuccess(){
        let url = URL(string: "https://a-url.com")!
        
        let subscription: Set<AnyCancellable> = []
        let service = MockNetworkService()
        let sut = NewsFromNetwork(service, subscription: subscription)
        
        service.isValidCase = true
        
        let expectedNews = createNews()
        service.news = expectedNews
        
        let exp = expectation(description: "Wait for load completion")
        
        sut.fetch(request: URLRequest(url: url)){ result in
            switch result{
            
            case let .success(news):
                XCTAssertEqual(news, expectedNews)
            default:
                XCTFail("should recieve NewsResponse")
            }
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 0.1)
    }
    
    //MARK: Helpers
    
    class MockNetworkService: NetworkService{
        var runCalls = 0
        var isValidCase = true
        var news: NewsResponse!
        
        override func run(_ request: URLRequest) -> AnyPublisher<NewsResponse, ApplicationError> {
            
            runCalls += 1
            if isValidCase{
                return Just(createNews()).setFailureType(to: ApplicationError.self).eraseToAnyPublisher()
            }else{
                return Fail<NewsResponse, ApplicationError>(error: .invalidResponse).eraseToAnyPublisher()
            }
        }
        
        private func createNews() -> NewsResponse{
            return news
        }
    }
    
    private func createNews() -> NewsResponse{
       let article = Article(id: "id", name: "name", title: "title", description: "desc", url: "url", urlToImage: "urltoimage", publishedAt: "publishedat", content: "content")

       let news = NewsResponse(status: "status", totalResults: 2, articles: [article,article])
       
       return news
   }
}

