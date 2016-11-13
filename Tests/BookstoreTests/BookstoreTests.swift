import XCTest
@testable import Bookstore

class BookstoreTests: XCTestCase {

    func test_getAllBooks() {

        let database = Database()
        database.queryBooks(with: Database.allBooks()) { books in 
            print("Returned books are \(books)")
            XCTAssertNotNil(books)
        }

    }

    func test_getBooksByAuthor() {

        let database = Database()
        database.queryBooks(with: Database.booksByAuthor(author: "George R. R. Martin")) { books in
            print("Books by George R.R. Martin are \(books)")
            XCTAssertNotNil(books)
        }

    }
    
    func test_getBooksInCart() {
        let database = Database()
        database.queryBooks(with: Database.booksInCart(userID: 1)) { books in
            print("Books in the cart 1 are: \(books)")
            XCTAssertNotNil(books)
        }
    }


    static var allTests : [(String, (BookstoreTests) -> () throws -> Void)] {
        return [
            ("test_getAllBooks", test_getAllBooks),
            ("test_getBooksByAuthor", test_getBooksByAuthor),
            ("test_getBooksInCart", test_getBooksInCart)
        ]
    }
}
