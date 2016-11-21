import SwiftKuery

final class BooksAuthorsTable: Table {

	let tableName = "books_authors"

	let authorID =  Column("author_id")
	let bookID =    Column("book_id")
	
}
