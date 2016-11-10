import SwiftKuery
import SwiftKueryPostgreSQL

final class Database {

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

func getShoppingCart( userID: Int, oncompletion: @escaping ([Book]) -> Void) {
    let connection = PostgreSQLConnection(host: Config.databaseHost, port: 5432, 
                        options: [.userName(Config.userName), 
                                  .password(Config.password), 
                                  .databaseName(Config.databaseName)])

    connection.connect() { error in 
        if let error = error {
            print(error)
        } else {
            let booksTable = BooksTable()
            let cartsTable = CartsTable()
            let s = Select(from: booksTable)
                .where(cartsTable.userID == userID)
                .leftJoin(cartsTable)
                .on(booksTable.id == cartsTable.bookID)
            s.execute(connection) { result in 
                if let (_, rows) = result.asRows {
                    let books = rows.flatMap( Book.init )
                    oncompletion(books)
                }
            }
        }
    }
}

}