import UIKit
import MapKit
import Promises

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let dataService = DataService()
    var places: [Place] = [] {
        didSet {
            mapView.addAnnotations(places)
        }
    }
    let locationManager = CLLocationManager()
    let region = 1000
    var regionRadius: CLLocationDistance { return CLLocationDistance(region * 2) }
    var location = CLLocation() {
        didSet {
            centerOnMapLocation(location: location)
            dataService.fetchDataFor(location: location, radius: region, keyword: "cafe")
                .then { self.places = $0 }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorizationStatus()
    }
    
    private func centerOnMapLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let currentLocation = CLLocation(latitude: locationValue.latitude, longitude: locationValue.longitude)
        if location.distance(from: currentLocation) > 100 {
            location = currentLocation
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let place = annotation as? Place else { return nil }
        let identifier = "placeMarker"
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
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

