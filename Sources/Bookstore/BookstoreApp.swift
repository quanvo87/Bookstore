import Kitura
import Foundation

import HeliumLogger
import SwiftyJSON
import SwiftKuery

public class BookstoreApp {
	
	let database = Database()
	let router = Router()

	public init() {

		router.get("/api/v1/books") {
		    request, response, callNextHandler in
		  
		    let selection: Select 
		    if let authorName = request.queryParameters["author"] {
		        selection = Database.booksByAuthor( author: authorName )
		    } else {
		        selection = Database.allBooks()
		    }

		    self.database.queryBooks(with: selection) { books in 
		        let json = JSON(books.dictionary)
		        response.send( json: json )
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

