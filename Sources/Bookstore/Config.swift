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

import CloudFoundryEnv
import Foundation
import LoggerAPI

class Config {

    static let sharedInstance = Config()
    
    var port: Int
    var ip: String
	var databaseHost = "localhost"
	var databasePort = Int32(5432)
	var userName     = "rfdickerson"
	var password     = "password"
	var databaseName = "bookstoredb"
    
    init() {
        
        do {
            let appEnv = try CloudFoundryEnv.getAppEnv()
            
            ip = appEnv.bind
            port = appEnv.port
            
            if let database = appEnv.getService(spec: "Bookstore-PostgreSQL") {
                print("Found the database! \(database)")
                
                if let credentials = database.credentials {
                    let uri = credentials["uri"].stringValue
                    print("URI is: \(uri)")
                    
                    if let url = URL(string: uri) {
                        
                        userName = url.user!
                        password = url.password!
                        databaseHost = url.host!
                        databasePort = Int32(url.port!)
                        databaseName = "compose"
                        
                        print("Password was \(password)")
                        
                    }
                    
                }
            } else {
                Log.verbose("Using default database")
            }
            
        } catch {
            print("Oops, something went wrong... Server did not start!")
            fatalError()
        }
        
    }

}

