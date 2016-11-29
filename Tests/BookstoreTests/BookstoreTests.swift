/**
 Copyright IBM Corporation 2016
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import XCTest

import PromiseKit

@testable import Bookstore

class BookstoreTests: XCTestCase {

    func test_getAllBooks() {

        let e = expectation(description: "Get all books")
        
        let database = Database()
        
        firstly {
            database.queryBooks(with: Database.allBooks())
        }.then { books in
            print("Returned books are \(books)")
            XCTAssertNotNil(books)
            XCTAssertGreaterThan(books.count, 1)
            e.fulfill()
        }.catch { error in
            XCTFail()
        }
        
        waitForExpectations(timeout: 10) { error in }

    }
    
    func test_getBooksLike() {
        
        let e = expectation(description: "Get similar books")
        
        let database = Database()
        
        firstly {
            database.queryBooks(with: Database.booksLike(title: "Storm"))
            }.then { books in
                print("Returned books are \(books)")
                XCTAssertNotNil(books)
                XCTAssertEqual(books.count, 1)
                
                let stormBook = books[0]
                XCTAssertEqual(stormBook.title, "A Storm of Swords")
                e.fulfill()
            }.catch { error in
                XCTFail()
        }
        
        waitForExpectations(timeout: 10) { error in }
        
    }

    func test_getBooksByAuthor() {

        let e = expectation(description: "Get all books")
        
        let database = Database()
        
        firstly {
            database.queryBooks(with: Database.booksByAuthor(author: "George R. R. Martin"))
        }.then { books in
            print("Books by George R.R. Martin are \(books)")
            XCTAssertNotNil(books)
            e.fulfill()
        }.catch { error in
            XCTFail()
        }
        
        waitForExpectations(timeout: 10) { error in }

    }
    
    func test_getBooksInCart() {
        
        let e = expectation(description: "Books in cart")
        
        let database = Database()
        
        firstly {
            database.queryBooks(with: Database.booksInCart(userID: 1))
        }.then { books in
            print("Books in the cart 1 are: \(books)")
            XCTAssertNotNil(books)
            e.fulfill()
        }.catch { error in
            XCTFail()
        }
        
        waitForExpectations(timeout: 10) { error in }
        
    }
    
//    func test_addBookToCart() {
//        
//        let e = expectation(description: "Books in cart")
//        
//        let database = Database()
//        
//        firstly {
//            database.addBookToCart(userID: 1, bookID: 3, quantity: 1)
//        }.then { result in
//             e.fulfill()
//        }.catch { error in
//                XCTFail()
//        }
//        
//        waitForExpectations(timeout: 10) { error in }
//    }


    static var allTests : [(String, (BookstoreTests) -> () throws -> Void)] {
        return [
            ("test_getAllBooks",        test_getAllBooks),
            ("test_getBooksByAuthor",   test_getBooksByAuthor),
            ("test_getBooksInCart",     test_getBooksInCart),
//            ("test_addBookToCart",      test_addBookToCart)
        ]
    }
}
