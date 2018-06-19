import Foundation
import CoreLocation
import Promises

class DataService {
    private var currentTask: URLSessionTask? = nil
    
    func fetchData(for location: CLLocation, radius: Int, keyword: String) -> Promise<[Place]> {
        currentTask?.cancel()
        return Promise<[Place]> { fulfill, reject in
            let request = self.getURLRequestWith(location: location,
                                            radius: radius,
                                            keyword: keyword)
            guard let finalRequest = request else { return reject(NetworkError.badRequest) }
            let task = URLSession.shared.dataTask(with: finalRequest) {data, response, error in
                if let error = error {
                    reject(error)
                    return
                }
                guard let responseData = data else
                {
                    reject(NetworkError.badData)
                    return
                }
                let decoder = JSONDecoder()
                let resultsContainer = try! decoder.decode(ResultsContainer.self, from: responseData)
                let places = self.placesFrom(results: resultsContainer.results)
                return fulfill(places)
            }
            task.resume()
            self.currentTask = task
        }
    }
    
    private func getURLRequestWith(location: CLLocation, radius: Int, keyword: String) -> URLRequest? {
        let baseUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        guard var components = URLComponents(string: baseUrl) else { return nil }
        let key = "AIzaSyCQ_m_zrIkYs3iE8IssBsXM2dh5XQIP_3Y"
        let locationText = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        let parameters: [String : String] = ["key": key,
                                             "query": keyword,
                                             "opennow": "true",
                                             "location": locationText,
                                             "radius": "\(radius)"
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
