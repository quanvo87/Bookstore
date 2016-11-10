import SwiftKuery

final class CartsTable: Table {

	let name = "carts"
	let userID = Column("user_id")
	let bookID = Column("book_id")
	let quantity = Column("quantity")

}