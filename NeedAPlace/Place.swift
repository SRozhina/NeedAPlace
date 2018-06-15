import MapKit
import Contacts

class Place: NSObject, MKAnnotation {
    let name: String
    let address: String
    var coordinate: CLLocationCoordinate2D
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        
        super.init()
    }
    
    var title: String? {
        return name
    }
    var subtitle: String? {
        return address
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey : subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        return mapItem
    }
    
}
