import Foundation
import CoreLocation
import Promises

class PlacesStorage {
    func fetchPlaces(for coordinate: CLLocationCoordinate2D, radius: Int, keyword: String) -> CancelableRequest<[Place]> {
        let pendingPromise = Promise<[Place]>.pending()
        
        let urlRequest = self.getURLRequestWith(coordinate: coordinate, radius: radius, keyword: keyword)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                pendingPromise.reject(error)
                return
            }
            guard let data = data else {
                pendingPromise.reject(PlacesStorageError.badData)
                return
            }
            
            let decoder = JSONDecoder()
            let placesResponce = try! decoder.decode(ApiPlacesResponce.self, from: data)
            let places = placesResponce.results.map(self.convertToPlace)
            pendingPromise.fulfill(places)
        }
        task.resume()
        
        return CancelableRequest<[Place]>(promise: pendingPromise, task: task)
    }
    
    private func getURLRequestWith(coordinate: CLLocationCoordinate2D, radius: Int, keyword: String) -> URLRequest {
        let baseUrl = "https://maps.googleapis.com/maps/api/place/textsearch/json"
        guard var components = URLComponents(string: baseUrl) else { fatalError("Bad url request") }
        
        let parameters = ["key": "AIzaSyCQ_m_zrIkYs3iE8IssBsXM2dh5XQIP_3Y",
                          "query": keyword,
                          "opennow": "true",
                          "location": "\(coordinate.latitude),\(coordinate.longitude)",
                          "radius": "\(radius)"]
        
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { fatalError("Bad url request") }
        return URLRequest(url: url)
    }
    
    private func convertToPlace(result: ApiPlaceResult) -> Place {
        let location = result.geometry.location
        return Place(name: result.name,
                     address: result.formatted_address,
                     coordinate: CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng),
                     rating: result.rating)
    }
}
