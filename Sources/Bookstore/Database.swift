import SwiftKuery
import SwiftKueryPostgreSQL

public class Database {

	func queryBooks(with selection: Select, oncompletion: @escaping ([Book]) -> Void ) {

	    let connection = PostgreSQLConnection(host: Config.databaseHost, port: Config.databasePort, 
	                        options: [.userName(Config.userName), 
	                                  .password(Config.password), 
	                                  .databaseName(Config.databaseName)])

	    connection.connect() { error in
	        if let error = error {
                print("Error connecting: \(error)")
	            oncompletion([])
	        }
	        else {
	            selection.execute(connection) { result in
	                if let rows = result.asRows {
                        
                        let fields = rowsToFields(rows: rows)
                        let books = fields.flatMap( Book.init(fields:) )
                        
                        oncompletion(books)
	                }
	            }

	        }
	    }
	}

	static func allBooks() -> Select {

		return Select(from: BooksTable())

	}

    // Requires many-to-many relationships
	static func booksByAuthor(author: String) -> Select {

		let booksTable = BooksTable()
//		let authorsTable = AuthorsTable()
//		let bookAuthorsTable = BookAuthorsTable()
//
//		return Select(from: booksTable)
//			.leftJoin(bookAuthorsTable)
//			.leftJoin(authorsTable)
//			.on(booksTable.bookID == bookAuthorsTable.bookID)
//			.on(authorsTable.authorID == bookAuthorsTable.authorID)
//			.where(authorsTable.authorName == author)
        return Select(from: booksTable)

	}

	static func booksInCart(userID: Int) -> Select {

		let booksTable = BooksTable()
	    let cartsTable = CartsTable()

	    return Select(from: booksTable)
	        .where(cartsTable.userID == userID)
	        .join(cartsTable)
	        .on(booksTable.bookID == cartsTable.bookID)

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
