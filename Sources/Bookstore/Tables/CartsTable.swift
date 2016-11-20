import SwiftKuery

final class CartsTable: Table {

	let tableName = "carts"
    
	let userID =    Column("user_id")
	let bookID =    Column("book_id")
	let quantity =  Column("quantity")

}
