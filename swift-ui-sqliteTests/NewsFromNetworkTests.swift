//
//  NewsFromNetworkTests.swift
//  swift-ui-sqliteTests
//
//  Created by Alok Subedi on 20/01/2021.
//

import XCTest
@testable import swift_ui_sqlite

class NewsFromNetworkTests: XCTestCase {
    func test_init_doesNotRequestDataFromUrl(){
        let service = MockNetworkService()
        let _ = NewsFromNetwork(service)
        
        XCTAssertEqual( service.runCalls, 0)
    }
    
    //MARK: Helpers
    
    class MockNetworkService: NetworkService{
        var runCalls = 0
    }
}

