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
        } catch let error {
            print(error, "while creating table")
        }
    }
    
    private func createTodosTable() throws {
        try connection.write { database in
            try database.create(table: "todos", ifNotExists: true) { (definition) in
                definition.autoIncrementedPrimaryKey("id")
                definition.column("user_id", .integer)
                definition.column("title", .text)
                definition.column("completed", .boolean)
            }
        }
    }
    
    
    private func createArticlesTable() throws {
        
        try connection.write { database in
            try database.create(table: "articles", ifNotExists: true) { (definition) in
                definition.autoIncrementedPrimaryKey("id")
                definition.column("name", .text)
                definition.column("title", .text)
                definition.column("description", .text)
                definition.column("content", .text)
            }
        }
    }
    
    
}
