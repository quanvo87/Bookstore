
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
        
        var rID: Any?
        var rTitle: Any?
        var rISBN: Any?
        var rYear: Any?
        
        fields.forEach() {
            switch $0 {
            case ("book_id", let rid):
                rID = rid
            case ("title", let rtitle):
                rTitle = rtitle
            case ("isbn", let risbn):
                rISBN = risbn
            case ("year", let ryear):
                rYear = ryear
            default:
                print("Some other field")
            }
        }
        
        print("rID was \(rID)")
        print("title was \(rTitle)")
        
        id = 0
        title = "hello"
        ISBN = "xxxxx"
        year = 2016
        
//        id = Int(rID as! String)!
//        title = rTitle as! String
//        ISBN = rISBN as! String
//        year = Int(rYear as! Int)!
        
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
