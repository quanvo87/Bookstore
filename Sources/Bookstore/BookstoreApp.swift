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

import Kitura
import Foundation

import HeliumLogger
import SwiftyJSON
import SwiftKuery

import PromiseKit

typealias UserID = Int

let defaultUserID = 1

struct BookCartRequest {
    let bookID:   Int
    let quantity: Int
}

enum BookSearchQuery {
    case all
    case byAuthor(String)
    case byTitle(String)
}

func processQuery(_ request: RouterRequest) throws -> BookSearchQuery {
    
    if let authorName = request.queryParameters["author"] {
        return BookSearchQuery.byAuthor(authorName)
    }
    else if let title = request.queryParameters["title"] {
        
        if title == "" { throw BookstoreError.invalidLengthQuery(title) }
        return BookSearchQuery.byTitle(title)
        
    } else {
        return BookSearchQuery.all
    }
    
}

func selectBooks(_ query: BookSearchQuery) -> Select {
    switch query {
    case .all:
        return Database.allBooks()
    case .byAuthor(let author):
        return Database.booksByAuthor( author: author )
    case .byTitle(let title):
        return Database.booksLike(title: title)
    }
}

func authenticate(_ request: RouterRequest) throws -> Promise<UserID> {
    return Promise { fulfill, reject in
        fulfill(defaultUserID)
    }
}

func processCartRequest(_ request: RouterRequest) throws -> BookCartRequest {
    if let json = request.json {
        let bookID   = json["book_id"].intValue
        let quantity = json["quantity"].intValue
        
        return BookCartRequest(bookID: bookID, quantity: quantity)
        
    } else {
        throw BookstoreError.badRequest
    }
}

public class BookstoreApp {
    
    let database = Database()
    let router = Router()
    
    let queue = DispatchQueue(label: "com.bookstore.web", attributes: .concurrent)
    
    public init() {
        
        router.post("*", middleware: BodyParser())
        
        router.get("/api/v1/books") {
            request, response, callNextHandler in
            
            let _ = firstly { () -> Promise<[Book]> in
                
                try request |> processQuery |> selectBooks |> self.database.queryBooks(with:)
                
                }.then (on: self.queue) { books in
                    
                    JSON(books.dictionary) |> response.send(json:)
                    
                }.catch(on: self.queue) { error in
                    
                    response.status(.badRequest)
                    response.send(error.localizedDescription)
                    
                }.always(on: self.queue) {
                    
                    callNextHandler()
                    
            }
        }
        
        router.get("/api/v1/cart") {
            request, response, callNextHandler in
            
            let _ = firstly { () -> Promise<Int> in
                
                try authenticate(request)
                
                }.then (on: self.queue) { userID -> Promise<[Book]> in
                    
                    userID |> Database.booksInCart(userID:) |> self.database.queryBooks(with:)
                    
                }.then (on: self.queue) { books in
                    
                    JSON(books.dictionary) |> response.send(json:)
                    
                }.catch(on: self.queue) { error in
                    
                    response.status(.badRequest)
                            .send(error.localizedDescription)
                    
                }.always(on: self.queue) {
                    
                    callNextHandler()
                    
            }
        }
        
        router.post("/api/v1/cart") {
            request, response, callNextHandler in
            
            let _ = firstly { () -> Promise<Int> in
                
                try authenticate(request)
                
            }.then (on: self.queue) { userID -> Promise<Void> in
                
                let bookRequest = try processCartRequest(request)
                return self.database.addBookToCart(userID: userID, bookRequest: bookRequest)
            
            }.then (on: self.queue) {
              
                response.send("Added the book!")
            
            }.catch(on: self.queue) { error in
            
                response.status(.badRequest)
                    .send(error.localizedDescription)
                
            }.always(on: self.queue) {
                
                callNextHandler()
                
            }
            
        }
        
        
    }
    
    public func run() {
        
        let envVars = ProcessInfo.processInfo.environment
        let portString: String = envVars["PORT"] ?? envVars["CF_INSTANCE_PORT"] ??  envVars["VCAP_APP_PORT"] ?? "8090"
        let port = Int(portString) ?? 8090
        
        Kitura.addHTTPServer(onPort: port, with: router)
        Kitura.run()
    }
}

