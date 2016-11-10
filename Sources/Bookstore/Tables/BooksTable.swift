import SwiftKuery

final class BooksTable : Table {

    let name = "books"

    let bookID = Column("book_id")
    let title = Column("title")
    let ISBN = Column("isbn")
    
}