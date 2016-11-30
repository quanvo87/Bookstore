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

class Config {

    static let sharedInstance = Config()
    
    let port: Int
    let ip: String
	let databaseHost = "localhost"
	let databasePort = Int32(5432)
	let userName     = "rfdickerson"
	let password     = "password"
	let databaseName = "bookstoredb"
    
    init() {
        
        do {
            let appEnv = try CloudFoundryEnv.getAppEnv()
            
            ip = appEnv.bind
            port = appEnv.port
            
            print(appEnv.getServices())
            
        } catch {
            print("Oops, something went wrong... Server did not start!")
            fatalError()
        }
        
    }

}

