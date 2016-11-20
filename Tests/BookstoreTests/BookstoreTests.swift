import XCTest

import PromiseKit

@testable import Bookstore

class BookstoreTests: XCTestCase {

    func test_getAllBooks() {

        let database = Database()
        
        firstly {
            database.queryBooks(with: Database.allBooks())
        }.then { books in
            print("Returned books are \(books)")
            XCTAssertNotNil(books)
        }.catch { error in
            
            XCTFail()
        }

    }

    func test_getBooksByAuthor() {

        let database = Database()
        
        firstly {
            database.queryBooks(with: Database.booksByAuthor(author: "George R. R. Martin"))
        }.then { books in
            print("Books by George R.R. Martin are \(books)")
            XCTAssertNotNil(books)
        }.catch { error in
            XCTFail()
        }

    }
    
    func test_getBooksInCart() {
        
        let database = Database()
        
        firstly {
            database.queryBooks(with: Database.booksInCart(userID: 1))
        }.then { books in
            print("Books in the cart 1 are: \(books)")
            XCTAssertNotNil(books)
        }.catch { error in
            XCTFail()
        }
        
    }
    
    func test_addBookToCart() {
        
        let database = Database()
        
        let book = Book(id: 1, title: "A Game of Thrones", ISBN: "978-0553593716", year: 2003)
        
        database.addBookToCart(userID: 1, book: book, quantity: 1) {
            
        }
    }


    static var allTests : [(String, (BookstoreTests) -> () throws -> Void)] {
        return [
            ("test_getAllBooks", test_getAllBooks),
            ("test_getBooksByAuthor", test_getBooksByAuthor),
            ("test_getBooksInCart", test_getBooksInCart),
            ("test_addBookToCart", test_addBookToCart)
        ]
    }
}
