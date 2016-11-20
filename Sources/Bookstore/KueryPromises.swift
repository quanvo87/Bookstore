//
//  KueryPromises.swift
//  bookstore
//
//  Created by Robert F. Dickerson on 11/20/16.
//
//

import PromiseKit
import SwiftKuery

extension Connection {

    func connect() -> Promise<QueryError?> {
        return Promise { fulfill, reject in
            self.connect() { error in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(nil)
                }
            }
        }
    }
    
}

extension Query {

    func execute(_ connection: Connection ) -> Promise<QueryResult> {
        return Promise { fulfill, reject in
            self.execute( connection) { result in
                fulfill(result)
            }
        }
    }

}
