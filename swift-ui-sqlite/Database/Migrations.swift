//
//  Migrations.swift
//  swift-ui-sqlite
//
//  Created by Ravi Bastola on 1/1/21.
//

import Foundation
import GRDB

final class Migration {
    
    var connection: DatabasePool
    
    init(connection: DatabasePool) {
        self.connection = connection
    }
    
    func run() {
        do {
            try createTodosTable()
            try createArticlesTable()
            try createNewsTable()
        } catch let error {
            print(error, "while creating table")
        }
    }
    
    private func createTodosTable() throws {
        try connection.write { database in
            try database.create(table: "todo", ifNotExists: true) { (definition) in
                definition.autoIncrementedPrimaryKey("id")
                definition.column("userId", .integer)
                definition.column("title", .text)
                definition.column("completed", .boolean)
            }
        }
    }
    
    
    private func createArticlesTable() throws {
        
        try connection.write { database in
            try database.create(table: "article", ifNotExists: true) { (definition) in
                definition.autoIncrementedPrimaryKey("id")
                definition.column("name", .text)
                definition.column("title", .text)
                definition.column("description", .text)
                definition.column("content", .text)
            }
        }
    }
    
    private func createNewsTable() throws {
        
        try connection.write { database in
            try database.create(table: "news", ifNotExists: true) { (definition) in
                definition.autoIncrementedPrimaryKey("id")
                definition.column("status", .text)
                definition.column("totalResults", .integer)
                definition.column("articles", .text)
            }
        }
    }
}
