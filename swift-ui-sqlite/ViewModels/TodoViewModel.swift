//
//  TodoViewModel.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/2/21.
//

import Foundation
import Combine
import GRDB

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
    
    func fetch()  {
        
        if Reachability.isConnectedToNetwork() {
            var innerUrl = urlComponents
            innerUrl.path = "/todos"
            
            NetworkService.shared.run(URLRequest(url: innerUrl.url!), model: [TodoViewModel.Todo].self)
                .receive(on: RunLoop.main)
                .sink { (_) in
                    //
                } receiveValue: { (response) in
                    
                    self.todos = response
                    
                    QueueService.backgroundQueue.async { [weak self] in
                        do {
                            try self?.insertTo(response: response)
                        } catch let error {
                            print(error)
                        }
                    }
                }.store(in: &subscription)
        } else {
            
            do {
                let todos = try DatabaseManager.shared.connection?.read{ (db)  in
                    try TodoViewModel.Todo.fetchAll(db)
                }
                
                if let todos = todos {
                    self.todos = todos
                }
                
            } catch let error {
                print(error)
            }
        }
    }
    
    
    private func insertTo(response: [Todo]) throws  {
        
        print("inserting to db")
        let _ = try DatabaseManager.shared.connection?.write { (db) in
           
            try db.execute(sql: "DELETE from todos")
            
            try response.forEach({ (todo) in
                try db.execute(sql: "INSERT INTO todos (user_id,title,completed) VALUES(?,?,?)", arguments: [todo.userId, todo.title, todo.completed])
            })
            
            print("insertion completed")
        }
    }
}

extension TodoViewModel {
    
    struct Todo: Codable, Hashable, FetchableRecord, PersistableRecord {
        let userId: Int
        let id: Int
        let title: String
        let completed: Bool
        
        static var databaseTableName: String {
            return "todos"
        }
        
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
        
        static let databaseDecodingUserInfo: [CodingUserInfoKey: Any] = [.sqliteOrigin: true]
        
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
