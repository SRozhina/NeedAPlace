import Foundation
import CoreLocation

class DataService {
    func fetchDataFor(location: CLLocation, radius: Int, keyword: String,then completion: @escaping ([Place]) -> ()) {
        let request = getURLRequestWith(latitude: location.coordinate.latitude ,
                                        longitude: location.coordinate.longitude,
                                        radius: radius,
                                        keyword: keyword)
        guard let finalRequest = request else { return }
        let task = URLSession.shared.dataTask(with: finalRequest) { (data, response, error) in
            guard let responseData = data else { return }
            let decoder = JSONDecoder()
            let resultsContainer = try! decoder.decode(ResultsContainer.self, from: responseData)
            let places = self.placesFrom(results: resultsContainer.results)
            print(places)
            completion(places)
        }
        task.resume()
    }
    
    private func getURLRequestWith(latitude: Double, longitude: Double, radius: Int, keyword: String) -> URLRequest? {
        let baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
        guard var components = URLComponents(string: baseUrl) else { return nil }
        let key = "AIzaSyCQ_m_zrIkYs3iE8IssBsXM2dh5XQIP_3Y"
        let parameters: [String : String] = ["key": key,
                                             "location": "\(latitude),\(longitude)",
                                             "radius": "\(radius)",
                                             "keyword": keyword]
        var items = [URLQueryItem]()
        for (name,value) in parameters {
            items.append(URLQueryItem(name: name, value: value))
        }
        components.queryItems = items
        guard let url = components.url else { return nil }
        print(url)
        return URLRequest(url: url)
    }
    
    private func placesFrom(results: [Results]) -> [Place] {
        return results.map { Place(name: $0.name,
                                   address: $0.vicinity,
                                   coordinate: CLLocationCoordinate2D(latitude: $0.geometry.location.lat,
                                                                      longitude: $0.geometry.location.lng))
                            }
    }
}
