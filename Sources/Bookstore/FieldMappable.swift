
protocol FieldMappable {

	var fields: [String: Any] { get }

	init?(titles: [String], rows: [String])

}