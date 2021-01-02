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
        
        let count = try! DatabaseManager.shared.connection!.scalar(todoTable.count)
        
        if Reachability.isConnectedToNetwork() && (count < 0) {
            var innerUrl = urlComponents
            innerUrl.path = "/todos"
            
            NetworkService.shared.run(URLRequest(url: innerUrl.url!), model: [TodoViewModel.Todo].self)
                .receive(on: RunLoop.main)
                .sink { (_) in
                    //
                } receiveValue: { (response) in
                    
                    QueueService.backgroundQueue.async { [weak self] in
                        self?.saveToDatabase(response: response)
                    }
                    
                    self.todos = response
                    
                }.store(in: &subscription)
        } else {
            
            do {
                self.todos = try DatabaseManager.shared.connection!.prepare(todoTable).map { row in
                    return try row.decode()
                }
                
            } catch let error {
                print(error, "here")
            }
        }
    }
    
    private func saveToDatabase(response: [Todo]) {
        
        print("inserting to db")
        let connection = DatabaseManager.shared.connection
        do {
            for todo in response {
                try connection?.run("INSERT INTO todos (userId,title,completed) VALUES (?,?,?)", [todo.userId, todo.title, todo.completed])
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
        
//        enum CodingKeys: String, CodingKey {
//            case userId = "userId"
//            case id
//            case title
//            case completed
//        }
    }
}
