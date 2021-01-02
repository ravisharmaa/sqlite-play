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
    
    @Published private (set)var todos: [Todo] = []
    
    //MARK:- Fetch from database or from connection
    
    func fetch() {
        if Reachability.isConnectedToNetwork() {
           
            var innerUrl = urlComponents
           
            innerUrl.path = "/todos"
            
            NetworkService.shared.run(URLRequest(url: innerUrl.url!), model: [TodoViewModel.Todo].self)
                .receive(on: RunLoop.main)
                .sink { (_) in
                    //
                } receiveValue: { (response) in
                    
                    let queue = DispatchQueue(label: "com.gcd.simpleQueue")

                    queue.async { [self] in
                        saveToDatabase(response: response)
                    }
                    
                    self.todos = response
                    
                    
                }.store(in: &subscription)
        } else {
            let todoTable = Migration.getTableObject(name: "todos")
            
            do {
                let todos: [TodoViewModel.Todo] = try DatabaseManager.shared.connection!.prepare(todoTable).map({ row in
                    return try row.decode()
                })
                
                print(todos)
                
            } catch let error {
                print(error)
            }
            
        }
    }
    
    private func saveToDatabase(response: [Todo]) {
        print("inserting to db")
        
        let connection = DatabaseManager.shared.connection
        
        do {
            for todo in response {
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
        
        enum CodingKeys: String, CodingKey {
            case userId
            case id
            case title
            case completed
        }
        
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
            self.completed = try container.decodeIfPresent(Bool.self, forKey: .completed) ?? false
            self.userId = try container.decode(Int.self, forKey: .userId)
            self.title = try container.decodeIfPresent(String.self, forKey: .title) ?? "hello"
        }
 
    }
}
