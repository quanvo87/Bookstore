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
	            oncompletion([])
	        }
	        else {
	            selection.execute(connection) { result in
	                if let (_, rows) = result.asRows {
	                   let books = rows.flatMap( Book.init )
	                   oncompletion(books)
	                }
	            }

	        }
	    }
	}

	static func allBooks() -> Select {

		return Select(from: BooksTable())

	}

	static func booksByAuthor(author: String) -> Select {

		let booksTable = BooksTable()
		let authorsTable = AuthorsTable()
		let bookAuthorsTable = BookAuthorsTable()

		return Select(from: booksTable)
			.leftJoin(bookAuthorsTable)
			.leftJoin(authorsTable)
			.on(booksTable.bookID == bookAuthorsTable.bookID)
			.on(authorsTable.authorID == bookAuthorsTable.authorID)
			.where(authorsTable.authorName == author)

	}

	static func booksFromCart(userID: Int) -> Select {

		let booksTable = BooksTable()
	    let cartsTable = CartsTable()

	    return Select(from: booksTable)
	        .where(cartsTable.userID == userID)
	        .leftJoin(cartsTable)
	        .on(booksTable.bookID == cartsTable.bookID)

	}

}