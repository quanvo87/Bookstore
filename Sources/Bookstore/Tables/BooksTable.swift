import SwiftKuery

final class BooksTable : Table {

    let tableName = "books"

    let bookID =    Column("book_id")
    let title =     Column("title")
    let ISBN =      Column("isbn")
    let year =      Column("year")
    
}
