//
//  NewsViewModel.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/3/21.
//

import Foundation
import Combine
import GRDB

final class NewsViewModel: BaseViewModel {
    
    override var urlComponents: URLComponents  {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "newsapi.org"
        return component
    }
    
    @Published private (set) var articles: [NewsResponse.Article] = []
    
    let connection = DatabaseManager.shared.connection
    
    func fetch(status: Bool) {
        !status ? fromNetwork() : fromDatabase()
    }
    
    fileprivate func fromNetwork() {
        
        var innerUrl = urlComponents
        
        innerUrl.path = "/v2/top-headlines"
        
        var urlQueryItem: [URLQueryItem] = []
        
        let queryItems: [String: String]  = [
            "country": "us",
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
                
                print(newsResponse)
                
                QueueService.backgroundQueue.async { [self] in
                    do {
                        try save(newsResponse)
                    } catch let error {
                        print(error)
                    }
                }
                
                articles = newsResponse.articles
                
            }.store(in: &subscription)
    }
    
    
    func save(_ articles: NewsResponse) throws {
        
        print("inserting to db")
        
        let _ = try DatabaseManager.shared.connection?.write { (db) in
            
            //try db.execute(sql: "DELETE from articles")
            
            //try articles.forEach({ (article) in
            let jsonEncoder = JSONEncoder()
            let data = try jsonEncoder.encode(articles.articles)
            try db.execute(sql: "INSERT INTO news (status,totalResults,articles) VALUES(?,?,?)", arguments: [articles.status, articles.totalResults, data ])
            
            //})
            
            print("insertion completed")
        }
    }
    
    fileprivate func fromDatabase() {
        do {
            let todos = try DatabaseManager.shared.connection?.read{ (db)  in
                try NewsResponse.fetchAll(db)
            }
            
            if let todos = todos {
                print(todos)
            }
            
        } catch let error {
            print(error)
        }
    }
    
}

extension NewsViewModel {
    
    struct NewsResponse: Codable, Hashable, FetchableRecord, PersistableRecord {
        
        let status: String
        let totalResults: Int
        
        let articles: [Article]
        
        static let databaseDecodingUserInfo: [CodingUserInfoKey: Any] = [.sqliteOrigin: true]
        
        static var databaseTableName: String {
             return "news"
        }
        
        struct Article: Hashable {
            let id: String?
            let name: String?
            let title: String
            let description: String?
            let url: String?
            let urlToImage: String?
            let publishedAt: String?
            let content: String?
            let uuid: UUID = UUID()
            
            static let databaseDecodingUserInfo: [CodingUserInfoKey: Any] = [.sqliteOrigin: true]
           
            enum AricleOfflineCodingKeys: CodingKey {
                case name, title, description, content, urlToImage, publishedAt, source, url, id
            }
            
            enum ArticleCodingKeys: CodingKey {
                case title, description, url, urlToImage, publishedAt, content, source, id, name
            }
        }
    }
}

extension NewsViewModel.NewsResponse.Article: Codable, FetchableRecord, PersistableRecord {
    
    enum NestedSourceKeys: CodingKey {
        case id, name
    }
    

    init(from decoder: Decoder) throws {
        
        if let origin = decoder.userInfo[.sqliteOrigin] as? Bool, origin == true {
            let container = try decoder.container(keyedBy: AricleOfflineCodingKeys.self)
            description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
            content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
            title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
            self.publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
            self.url = try container.decodeIfPresent(String.self, forKey: .url)
            self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
            let nestedContainer = try container.nestedContainer(keyedBy: NestedSourceKeys.self, forKey: .source)
            self.id = try nestedContainer.decodeIfPresent(String.self, forKey: .id)
            self.name = try nestedContainer.decode(String.self, forKey: .name)
        } else {
            let container = try decoder.container(keyedBy: ArticleCodingKeys.self)
            self.title = try container.decode(String.self, forKey: .title)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
            self.url = try container.decodeIfPresent(String.self, forKey: .url)
            self.urlToImage = try container.decodeIfPresent(String.self, forKey: .urlToImage)
            self.publishedAt = try container.decodeIfPresent(String.self, forKey: .publishedAt)
            self.content = try container.decodeIfPresent(String.self, forKey: .content)
           // let nestedContainer = try container.nestedContainer(keyedBy: NestedSourceKeys.self, forKey: .source)
            self.id = try container.decodeIfPresent(String.self, forKey: .id)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
        }
    }
}
