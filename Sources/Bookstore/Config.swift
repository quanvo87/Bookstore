/**
 Copyright IBM Corporation 2017
 
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

import Foundation
import LoggerAPI
import Configuration
import CloudFoundryConfig

class Config {

    static let sharedInstance = Config()
    
    var port: Int
	var databaseHost = "localhost"
	var databasePort = Int32(5432)
	var userName     = "username"
	var password     = "password"
	var databaseName = "bookstoredb"
    var serviceName  = "Bookstore-postgresql"
    
    init() {
        
        let manager = ConfigurationManager()
        manager.load(.environmentVariables)
        
        port = manager.port
        
        do {
            let postgresConfig = try manager.getPostgreSQLService(name: serviceName)
            userName = postgresConfig.username
            password = postgresConfig.password
            databaseHost = postgresConfig.host
            databasePort = Int32(postgresConfig.port)
            databaseName = "compose"
            
        } catch {
            Log.verbose("Using default database")
        }
        
    }

}

