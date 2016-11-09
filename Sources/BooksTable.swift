import SwiftKuery

final class BooksTable : Table {
    let name = "books"
    let id = Column("id")
    let title = Column("title")
    let ISBN = Column("isbn")
}