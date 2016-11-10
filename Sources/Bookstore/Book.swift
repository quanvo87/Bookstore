struct Book {
    
    let id: Int 
    let title: String 
    let ISBN: String 
    let year: Int 

    
}

extension Book: FieldMappable {

    init?(titles: [String], rows: [Any?]) {
        guard let rID = rows[0] else {
            return nil 
        } 
        guard let rTitle = rows[1] else {
            return nil 
        }
        guard let rISBN = rows[2] else {
            return nil 
        }
        guard let rYear = rows[3] else {
            return nil 
        }

        id = Int(rID as! String)!
        title = rTitle as! String 
        ISBN = rISBN as! String 
        year = Int(rYear as! String)!
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