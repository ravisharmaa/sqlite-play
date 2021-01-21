//
//  NewsViewModel.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/3/21.
//

import Foundation
import Combine

final class NewsViewModel {
    var subscription: Set<AnyCancellable> = []
    
    @Published private (set) var articles: [Article] = []
    
    func fetch() {
        
    }
    
    fileprivate func fromNetwork() {
        let newsFromNetwork = NewsFromNetwork(subscription: subscription)
        newsFromNetwork.fetch(request: nil){ result in
            switch result{
            case let .success(news):
                self.articles = news.articles
            case .failure(_):
                break
            }
        }
    }
    
    func save(_ articles: [Article]) {
        
    }
}

