
typealias KueryRows = ([String], [[Any?]])
typealias Fields = [String: Any]

protocol FieldMappable {

	var fields: [String: Any] { get }

    init?( fields: Fields )

}


func rowsToFields(rows: KueryRows) -> [Fields] {
    
    let (titles, fieldRows) = rows
    
    var dicts = [Fields]()
    
    let t = fieldRows.map { Array(zip(titles, $0)) }
    // print(t)
    
    let y: [Fields] = t.map {
        var dicts = [String: Any]()
        
        $0.forEach {
            let (title, value) = $0
            dicts[title] = value
        }
        
        return dicts
    }
    
    // print(y)
    
    return y
    
}
