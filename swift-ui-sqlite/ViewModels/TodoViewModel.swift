//
//  TodoViewModel.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/2/21.
//

import Foundation
import Combine
import SQLite

class BaseViewModel {
    
    var subscription: Set<AnyCancellable> = []
    
    var urlComponents: URLComponents  {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "jsonplaceholder.typicode.com"
        return component
    }
}

class TodoViewModel: BaseViewModel {
    
    @Published private (set) var todos: [Todo] = []
    
    //MARK:- Fetch from database or from connection
    
    func fetch() {
        
        let todoTable = Migration.getTableObject(name: "todos")
        
        if Reachability.isConnectedToNetwork() {
            var innerUrl = urlComponents
            innerUrl.path = "/todos"
            
            NetworkService.shared.run(URLRequest(url: innerUrl.url!), model: [TodoViewModel.Todo].self)
                .receive(on: RunLoop.main)
                .sink { (_) in
                    //
                } receiveValue: { (response) in
                    
                    QueueService.backgroundQueue.async { [weak self] in
                        self?.insertTo(todoTable, response: response)
                    }
                    
                    self.todos = response
                    
                }.store(in: &subscription)
        } else {
            
            do {
                self.todos = try DatabaseManager.shared.connection!.prepare(todoTable).map { row in
                    let decoder = row.decoder(userInfo: [.sqliteOrigin: true])
                    return try Todo(from: decoder)
                }
                
            } catch let error {
                print(error)
            }
        }
    }
    
    private func insertTo(_ table: Table, response: [Todo]) {
        
        print("inserting to db")
        let connection = DatabaseManager.shared.connection
    
        do {
            // refresh the db before inserting
            try connection?.run(table.delete())
            
            try response.forEach { (todo) in
                try connection?.run("INSERT INTO todos (user_id,title,completed) VALUES (?,?,?)", [todo.userId, todo.title, todo.completed])
            }
            
            print("insertion completed")
            
        } catch let error {
            print(error)
        }
        
    }
}

extension TodoViewModel {
    
    struct Todo: Codable, Hashable {
        let userId: Int
        let id: Int
        let title: String
        let completed: Bool
        
        enum OfflineDecodingKeys: String, CodingKey {
            case userId = "user_id"
            case id
            case title
            case completed
        }
        
        enum OnlineDecodingKeys: String, CodingKey {
            case userId
            case id
            case title
            case completed
        }
        
        init(from decoder: Decoder) throws {
            if let origin = decoder.userInfo[.sqliteOrigin] as? Bool, origin == true {
                let container = try decoder.container(keyedBy: OfflineDecodingKeys.self)
                id = try container.decode(Int.self, forKey: .id)
                title = try container.decode(String.self, forKey: .title)
                userId = try container.decode(Int.self, forKey: .userId)
                completed = try container.decode(Bool.self, forKey: .completed)
            } else {
                let container = try decoder.container(keyedBy: OnlineDecodingKeys.self)
                id = try container.decode(Int.self, forKey: .id)
                title = try container.decode(String.self, forKey: .title)
                userId = try container.decode(Int.self, forKey: .userId)
                completed = try container.decode(Bool.self, forKey: .completed)
            }
        }
    }
}

extension CodingUserInfoKey {
    static let sqliteOrigin = CodingUserInfoKey(rawValue: "sqliteOrigin")!
    static let jsonOrigin = CodingUserInfoKey(rawValue: "jsonOrigin")!
}
