import SwiftKuery

final class AuthorsTable : Table {
    let name = "authors"
    let id = Column("id")
    let title = Column("name")
}