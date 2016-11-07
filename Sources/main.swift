import Kitura
import Foundation

import SwiftKuery
import SwiftKueryPostgreSQL

import HeliumLogger

let databaseHost = "localhost"
let userName = "rfdickerson"
let password = "password"
let databaseName = "bookstoredb"

final class BooksTable : Table {
    let name = "books"
    let id = Column("id")
    let title = Column("title")
    let ISBN = Column("isbn")
}

final class AuthorsTable : Table {
    let name = "authors"
    let id = Column("id")
    let title = Column("name")
}

struct Book {
    let id: Int 
    let title: String 
    let ISBN: String 
    let year: Int 

    init?( rows: [Any?]) {
        guard let rID = rows[0] else {
            return nil 
        } 
        guard let rTitle = rows[1] else {
            return nil 
        }
        guard let rISBN = rows[2] else {
            return nil 
        }
        guard let rYear = rows[3] else {
            return nil 
        }

        id = Int(rID as! String)!
        title = rTitle as! String 
        ISBN = rISBN as! String 
        year = Int(rYear as! String)!
    }
}

HeliumLogger.use()

func getAllBooks( oncompletion: @escaping ([Book]) -> Void ) {
    let connection = PostgreSQLConnection(host: databaseHost, port: 5432, 
                        options: [.userName(userName), 
                                .password(password), 
                                .databaseName(databaseName)])
    connection.connect() { error in
        if let error = error {
            print(error)
        }
        else {
            // Build and execute your query here.
            let booksTable = BooksTable()
            let s = Select(from: booksTable)
            s.execute(connection) { result in
                if let (_, rows) = result.asRows {
                   let books = rows.flatMap( Book.init )
                   oncompletion(books)
                }
            }

        }
    }
}

let router = Router()

router.get("/") {
    request, response, next in
    response.send("Hello, World!")
    getAllBooks { books in 
        print(books)
        next()
    }
}

// Look for environment variables for PORT
let envVars = ProcessInfo.processInfo.environment
let portString: String = envVars["PORT"] ?? envVars["CF_INSTANCE_PORT"] ??  envVars["VCAP_APP_PORT"] ?? "8090"
let port = Int(portString) ?? 8090

Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
