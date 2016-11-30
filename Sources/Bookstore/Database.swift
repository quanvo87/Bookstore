import Dispatch

import SwiftKuery
import SwiftKueryPostgreSQL
import PromiseKit

public class Database {
    
    let queue = DispatchQueue(label: "com.bookstore.database", attributes: .concurrent)
    
    static let booksTable = BooksTable()
    static let cartsTable = CartsTable()
    
    private func createConnection() -> Connection {
        return PostgreSQLConnection(host: Config.sharedInstance.databaseHost, port: Config.sharedInstance.databasePort,
                                    options: [.userName(Config.sharedInstance.userName),
                                              .password(Config.sharedInstance.password),
                                              .databaseName(Config.sharedInstance.databaseName)])
    }
    
    func queryBooks(with selection: Select) -> Promise<[Book]> {
        
        let connection = createConnection()
        
        return firstly {
            connection.connect()
        }
        .then(on: queue) { result -> Promise<QueryResult> in
            selection.execute(connection)
        }
        .then(on: queue) { result -> ResultSet in
            guard let resultSet = result.asResultSet else { throw BookstoreError.noResult }
            return resultSet
        }.then(on: queue) { resultSet -> [Book] in
            let fields = resultToRows(resultSet: resultSet)
            return fields.flatMap( Book.init(fields:) )
        }.always(on: queue) {
            connection.closeConnection()
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
            if let error = result.asError {
                throw error
            }
        }.always(on: queue) {
            connection.closeConnection()
        }
        
    }
    
    static func allBooks() -> Select {
        
        return Select(from: BooksTable())
        
    }
    
    static func booksByAuthor(author: String) -> Select {
        
        return Select(from: Database.booksTable)
            .where ( Database.booksTable.author == author )
        
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
