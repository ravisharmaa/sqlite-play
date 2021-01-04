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
            //createArticlesTable()
        } catch let error {
            print(error)
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
        
    /*
    private func createArticlesTable() {
        let table = Migration.getTableObject(name: "articles")
        
        let id = Expression<Int64>("id")
        let uuid = Expression<String>("uuid")
        let name = Expression<Int>("name")
        let title = Expression<String?>("title")
        let description = Expression<String?>("description")
        let content = Expression<String?>("content")
        
        do {
            
            try self.connection.run(table.create(ifNotExists: true, block: { (builder) in
                builder.column(id, primaryKey: .autoincrement)
                builder.column(uuid, unique: true)
                builder.column(name)
                builder.column(title)
                builder.column(description)
                builder.column(content)
            }))
            
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    private func createCompaniesTable() {
        
        let table = Migration.getTableObject(name: "companies")
        
        let id = Expression<Int64>("id")
        let name = Expression<String?>("name")
        let photoURL = Expression<String?>("photo_url")
        let founded = Expression<String?>("founded")
        
        do {
            
            try connection.run(table.create(ifNotExists: true, block: { (builder) in
                builder.column(id, primaryKey: true)
                builder.column(name)
                builder.column(photoURL, defaultValue: nil)
                builder.column(founded, defaultValue: nil)
            }))
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    
    class func getTableObject(name: String) -> Table {
        return Table(name)
    }
 */
}
