//
//  NewsFromNetworkTests.swift
//  swift-ui-sqliteTests
//
//  Created by Alok Subedi on 20/01/2021.
//

import XCTest
@testable import swift_ui_sqlite

class NewsNetorkService: NetworkService{
    
}

class NewsFromNetworkTests: XCTestCase {
    func test_init_doesNotRequestDataFromUrl(){
        let service = NewsNetorkService()
        let sut = NewsFromNetwork()
    }
}

