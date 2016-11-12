
typealias KueryRows = ([String], [[Any?]])
typealias Fields = [(String, Any)]

protocol FieldMappable {

	var fields: [String: Any] { get }

    init?( fields: Fields )

}


func rowsToFields(rows: KueryRows) -> [Fields] {
    
    let (titles, fields) = rows
    
    let r = fields.flatMap {
        zip(titles, $0.flatMap(){$0})
    }
    
    print(r)
    
    return [r]
    
}
