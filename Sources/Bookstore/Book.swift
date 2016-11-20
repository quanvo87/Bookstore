
struct Book {
    
    let id: Int
    let title: String
    let ISBN: String
    let year: Int

}

extension Book: FieldMappable {
    
    internal var fields: [String : Any] {
        return [
            "book_id":  id,
            "title":    title,
            "isbn":     ISBN
        ]
    }
    
    
    init?(fields: [String: Any]) {
        
        if let fieldID = fields["book_id"] {
            id = Int(fieldID as! String)!
        } else {
            return nil
        }
        
        title = fields["title"] as! String
        ISBN = fields["isbn"] as! String
        
        if let fieldYear = fields["year"] {
            year = Int(fieldYear as! String)!
        } else {
            return nil
        }
        
        
    }
    
}

extension Book: DictionaryConvertible {
    var dictionary: [String: Any] {
        return [
            "book_id":  id,
            "title":    title,
            "ISBN":     ISBN,
            "year":     year
        ]
    }
}
