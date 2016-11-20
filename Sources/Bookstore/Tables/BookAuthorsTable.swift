import SwiftKuery

final class BookAuthorsTable: Table {

	let tableName = "book_author"

	let authorID =  Column("author_id")
	let bookID =    Column("book_id")
	
}
