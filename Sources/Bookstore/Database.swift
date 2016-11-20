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
    
    static func allBooks() -> Select {
        
        return Select(from: BooksTable())
        
    }
    
    // TODO: Requires many-to-many relationships
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
        
        return Select(from: Database.booksTable)
            .where(Database.cartsTable.userID == userID)
            .join(Database.cartsTable)
            .on(Database.booksTable.bookID == Database.cartsTable.bookID)
        
    }
    
    func addBookToCart(userID: Int, book: Book, quantity: Int, onCompletion: @escaping () -> Void ) {
        
        let cartsTable = CartsTable()
        
        let insert = Insert(into: cartsTable,
                            columns: [
                                cartsTable.bookID,
                                cartsTable.quantity,
                                cartsTable.userID
            ],
                            values: [
                                String(book.id),
                                String(quantity),
                                String(userID)
            ])
        
        let connection = PostgreSQLConnection(host: Config.databaseHost, port: Config.databasePort,
                                              options: [.userName(Config.userName),
                                                        .password(Config.password),
                                                        .databaseName(Config.databaseName)])
        
        connection.connect() { error in
            if let error = error {
                print("Error connecting: \(error)")
                onCompletion()
            }
            
            connection.execute(query: insert) { result in
                
                print("Adding book resulted in \(result)")
                onCompletion()
            }
            
            
        }
        
    }
    
}
