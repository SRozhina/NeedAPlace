struct ApiPlaceResult : Codable {
	let geometry : ApiGeometry
	let name : String
	let formatted_address : String
    let rating: Double?
}
