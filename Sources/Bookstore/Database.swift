import Dispatch

import SwiftKuery
import SwiftKueryPostgreSQL
import PromiseKit

public class Database {
    
    let queue = DispatchQueue(label: "com.bookstore.database", attributes: .concurrent)
    
    static let booksTable = BooksTable()
    static let cartsTable = CartsTable()
    
    private func createConnection() -> Connection {
        return PostgreSQLConnection(host: Config.databaseHost, port: Config.databasePort,
                                    options: [.userName(Config.userName),
                                              .password(Config.password),
                                              .databaseName(Config.databaseName)])
    }
    
    func queryBooks(with selection: Select) -> Promise<[Book]> {
        
        let connection = createConnection()
        
        return firstly {
            connection.connect()
        }
        .then(on: queue) { result -> Promise<QueryResult> in
                print(result)
                return selection.execute(connection)
        }
        .then(on: queue) { result -> [Book] in
                
            if let rows = result.asRows {
                    
                let fields = rowsToFields(rows: rows)
                let books = fields.flatMap( Book.init(fields:) )
                    
                return books
                    
            } else {
                throw BookstoreError.noResult
            }
        }
    }
    
    func addBookToCart(userID: Int, bookRequest: BookCartRequest) -> Promise<Void> {
        
        
        let insert = Insert(into: Database.cartsTable,
                            columns: [
                                Database.cartsTable.bookID,
                                Database.cartsTable.quantity,
                                Database.cartsTable.userID
            ],
                            values: [
                                String(bookRequest.bookID),
                                String(bookRequest.quantity),
                                String(userID)
            ])
        
        
        let connection = createConnection()
        
        return firstly {
            connection.connect()
        }.then(on: queue) {
            insert.execute(connection)
        }.then(on: queue) { result -> Void in
            print(result)
        }
        
    }
    
    static func allBooks() -> Select {
        
        return Select(from: BooksTable())
        
    }
    
    static func booksByAuthor(author: String) -> Select {
        
        return Select(from: Database.booksTable)
        
    }
    
    static func booksLike(title: String) -> Select {
        return Select(from: Database.booksTable)
            .where( Database.booksTable.title.like("%"+title+"%"))
            .order( by: .ASC(booksTable.title))
            .limit(to: 20)
    }
    
    static func booksInCart(userID: Int) -> Select {
        
        return Select(from: Database.cartsTable)
            .where(Database.cartsTable.userID == userID)
            .join(Database.booksTable)
            .using(Database.cartsTable.bookID)
        
    }
    
    
    
}
