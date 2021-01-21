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
    
    func test_fetch_requestsDataFromURL() {
        
        let url = URL(string: "https://a-url.com")!
        
        let service = MockNetworkService()
        let sut = NewsFromNetwork(service)
        
        sut.fetch(request: URLRequest(url: url)){  }
        
        XCTAssertEqual( service.runCalls, 1)
    }
    
    //MARK: Helpers
    
    class MockNetworkService: NetworkService{
        var runCalls = 0
        
        override func run(_ request: URLRequest) -> AnyPublisher<NewsResponse, ApplicationError> {
            
            runCalls += 1

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

            return Just(news).setFailureType(to: ApplicationError.self).eraseToAnyPublisher()

        }
    }
}

