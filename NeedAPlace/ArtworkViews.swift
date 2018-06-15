import Foundation
import MapKit
//
//class ArtworkMarkerView: MKMarkerAnnotationView {
//    override var annotation: MKAnnotation? {
//        willSet {
//            guard let artwork = newValue as? Artwork else { return }
//            canShowCallout = true
//            calloutOffset = CGPoint(x: -5, y: 5)
//            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            markerTintColor = artwork.markerTintColor
//            //glyphText = String(artwork.discipline.first!)
//            if let imageName = artwork.imageName {
//                glyphImage = UIImage(named: imageName)
//            } else {
//                glyphImage = nil
//            }
//        }
//    }
//}
//
class ArtworkView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? Place else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            let mapsButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
            mapsButton.setBackgroundImage(UIImage(named: "Maps-icon"), for: UIControlState())
            rightCalloutAccessoryView = mapsButton
            
            let detailedLabel = UILabel()
            detailedLabel.numberOfLines = 0
            detailedLabel.font = detailedLabel.font.withSize(12)
            detailedLabel.text = artwork.subtitle
            detailCalloutAccessoryView = detailedLabel
        }
    }
}
