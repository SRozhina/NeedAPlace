import UIKit
import MapKit
import Promises

class ViewController: UIViewController {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private let placesStorage = PlacesStorage()
    private var places: [Place] = []
    private let locationManager = CLLocationManager()
    private let region = 1000
    private var regionRadius: CLLocationDistance { return CLLocationDistance(region * 2) }
    private var searchText: String { get { return searchBar.text ?? "" } }
    private var location = CLLocation()
    private let locationUpdateDistance: CLLocationDistance = 100
    private var placesRequest: CancelableRequest<[Place]>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.setImage(UIImage(named: "SelfLocation"), for: .bookmark, state: .normal)
        
        mapView.showsUserLocation = true
        
        configureLocationManager()
    }
    
    @IBAction private func showLocationTapped(_ sender: Any) {
        centerOnMap(location: location, regionRadius: regionRadius)
    }
    
    private func centerOnMap(location: CLLocation, regionRadius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func configureLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func updateLocation(location: CLLocation) {
        centerOnMap(location: location, regionRadius: regionRadius)
        
        placesRequest?.cancel()
        placesRequest = placesStorage.fetchPlaces(for: location.coordinate, radius: region/2, keyword: searchText)
        placesRequest!.promise.then { places in
            self.mapView.removeAnnotations(self.places)
            self.places = places
            self.mapView.addAnnotations(places)
        }
        
        self.location = location
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = manager.location else { return }
        if location.distance(from: currentLocation) > locationUpdateDistance {
            updateLocation(location: currentLocation)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let place = annotation as? Place else { return nil }
        
        let identifier = "placeMarker"
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            return dequeuedView
        }
        
        return createAnnotationView(with: identifier, for: place)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Place
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    private func createAnnotationView(with identifier: String, for place: Place) -> MKMarkerAnnotationView {
        let view = MKMarkerAnnotationView(annotation: place, reuseIdentifier: identifier)
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        
        let mapsButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControlState())
        view.rightCalloutAccessoryView = mapsButton
        
        let detailedLabel = UILabel()
        detailedLabel.numberOfLines = 0
        detailedLabel.font = detailedLabel.font.withSize(12)
        let additionalDescription = place.rating != nil ? "\nRating: \(place.rating!)" : ""
        detailedLabel.text = place.address + additionalDescription
        view.detailCalloutAccessoryView = detailedLabel
        
        return view
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        updateLocation(location: locationManager.location!)
    }
}


