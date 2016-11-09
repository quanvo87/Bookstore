import Kitura
import Foundation

import SwiftKuery
import SwiftKueryPostgreSQL

import HeliumLogger
import SwiftyJSON

HeliumLogger.use()

func getAllBooks( oncompletion: @escaping ([Book]) -> Void ) {
    let connection = PostgreSQLConnection(host: Config.databaseHost, port: 5432, 
                        options: [.userName(Config.userName), 
                                .password(Config.password), 
                                .databaseName(Config.databaseName)])
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

router.get("/api/v1/books") {
    request, response, callNextHandler in
  
    getAllBooks { books in 
        let json = JSON(books.dictionary)
        print(json)
        response.send( json: json )
        callNextHandler()
    }
}

// Look for environment variables for PORT
let envVars = ProcessInfo.processInfo.environment
let portString: String = envVars["PORT"] ?? envVars["CF_INSTANCE_PORT"] ??  envVars["VCAP_APP_PORT"] ?? "8090"
let port = Int(portString) ?? 8090

Kitura.addHTTPServer(onPort: port, with: router)
Kitura.run()
