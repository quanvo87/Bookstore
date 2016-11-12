
typealias KueryRows = ([String], [[Any?]])
typealias Fields = [(String, Any)]

protocol FieldMappable {

	var fields: [String: Any] { get }

    init?( fields: Fields )

}


func rowsToFields(rows: KueryRows) -> [Fields] {
    
    let (titles, fields) = rows
    
    var enumerate = titles.enumerated()
    
    return [[("id", 2345), ("title", "hello")]]
    
}
