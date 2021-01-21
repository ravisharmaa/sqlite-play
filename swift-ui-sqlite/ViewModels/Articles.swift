//
//  Articles.swift
//  swift-ui-sqlite
//
//  Created by Alok Subedi on 20/01/2021.
//

import Foundation

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

extension Article: Decodable {
    
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
