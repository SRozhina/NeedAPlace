import Foundation
import CoreLocation
import Promises

class DataService {
    func fetchDataFor(location: CLLocation, radius: Int, keyword: String) -> Promise<[Place]> {
        let request = getURLRequestWith(location: location,
                                        radius: radius,
                                        keyword: keyword)
        guard let finalRequest = request else { return Promise(NetworkError.badRequest) }
        return URLSession.shared.dataTaskPromised(with: finalRequest)
            .then { data in
                let decoder = JSONDecoder()
                let resultsContainer = try! decoder.decode(ResultsContainer.self, from: data)
                let places = self.placesFrom(results: resultsContainer.results)
                return Promise(places)
            }
    }
    
    private func getURLRequestWith(location: CLLocation, radius: Int, keyword: String) -> URLRequest? {
        let baseUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        guard var components = URLComponents(string: baseUrl) else { return nil }
        let key = "AIzaSyCQ_m_zrIkYs3iE8IssBsXM2dh5XQIP_3Y"
        let locationText = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        let parameters: [String : String] = ["key": key,
                                             "location": locationText,
                                             "radius": "\(radius)",
                                             "query": keyword,
                                             "opennow": "true"
                                            ]
        var items = [URLQueryItem]()
        for (name,value) in parameters {
            items.append(URLQueryItem(name: name, value: value))
        }
        components.queryItems = items
        guard let url = components.url else { return nil }
        return URLRequest(url: url)
    }
    
    private func placesFrom(results: [Results]) -> [Place] {
        return results.map { Place(name: $0.name,
                                   address: $0.formatted_address,
                                   coordinate: CLLocationCoordinate2D(latitude: $0.geometry.location.lat,
                                                                      longitude: $0.geometry.location.lng),
                                   rating: $0.rating)
                            }
    }
}
