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
    
    var urlComponents: URLComponents  {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "newsapi.org"
        return component
    }
    
    @Published private (set) var articles: [NewsResponse.Article] = []
    
    func fetch() {
        
    }
    
    fileprivate func fromNetwork() {
        
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
        
        NetworkService.shared.run(URLRequest(url: innerUrl.url!), model: NewsResponse.self)
            .receive(on: RunLoop.main)
            .sink { (_) in
                //
            } receiveValue: { [self] (newsResponse) in
                
                QueueService.backgroundQueue.async { [weak self] in
                    self?.save(newsResponse.articles)
                }
                
                articles = newsResponse.articles
                
            }.store(in: &subscription)
    }
    
    func save(_ articles: [NewsResponse.Article]) {
        
    }
}

extension NewsViewModel {
    
    struct NewsResponse: Decodable, Hashable {
        
        let status: String
        let totalResults: Int
        
        let articles: [Article]
        
        struct Article:  Hashable {
            let id: String?
            let name: String
            let title: String
            let description: String?
            let url: String?
            let urlToImage: String?
            let publishedAt: String?
            let content: String?
            let uuid: UUID = UUID()
            
            enum ArticleCodingKeys: CodingKey {
                case title, description, url, urlToImage, publishedAt, content, source
            }
        }
    }
}

extension NewsViewModel.NewsResponse.Article: Decodable {
    
    enum NestedSourceKeys: CodingKey {
        case id, name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ArticleCodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
        self.publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        let nestedContainer = try container.nestedContainer(keyedBy: NestedSourceKeys.self, forKey: .source)
        self.id = try nestedContainer.decodeIfPresent(String.self, forKey: .id)
        self.name = try nestedContainer.decode(String.self, forKey: .name)
    }
}
