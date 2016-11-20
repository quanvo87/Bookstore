import SwiftKuery

final class AuthorsTable : Table {
    
    let tableName = "authors"

    let authorID    = Column("author_id")
    let authorName  = Column("name")
}
