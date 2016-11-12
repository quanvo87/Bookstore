
struct Book {
    
    let id: Int
    let title: String
    let ISBN: String
    let year: Int
    
    
}

extension Book: FieldMappable {
    
    internal var fields: [String : Any] {
        return [
            "id": id,
            "title": title,
            "isbn": ISBN
        ]
    }
    
    
    init?(fields: [(String, Any)]) {
        
        id = 0
        title = "hello"
        ISBN = ""
        year = 2016
        
//        id = Int(rID as! String)!
//        title = rTitle as! String
//        ISBN = rISBN as! String
//        year = Int(rYear as! String)!
        
    }
    
}

extension Book: DictionaryConvertible {
    var dictionary: [String: Any] {
        return [
            "id":    id,
            "title": title,
            "ISBN":  ISBN,
            "year":  year
        ]
    }
}
