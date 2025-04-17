import SwiftUI
import MapKit

class MainViewModel: ObservableObject {
    @Published var from: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.740979140527834, longitude: -73.98966672823792)
    
    @Published var to: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.73130329269146, longitude: -73.99705445144045)
    @Published var time: String = ""
    @Published var distance: String = ""
    
    
    func calcualteDistance() async {
//        let tempFrom = CLLocation(latitude: from.latitude, longitude: from.longitude)
//        let tempTo = CLLocation(latitude: to.latitude, longitude: to.longitude)
//        let res = (tempFrom.distance(from: tempTo) / 1000)
//        distance = String(format: "%.2f", res)
        let fromMarker = MKPlacemark(coordinate: from)
        let toMarker = MKPlacemark(coordinate: to)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: fromMarker)
        request.destination = MKMapItem(placemark: toMarker)
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        do {
           let results = try await directions.calculate()
            let route = results.routes.first
            distance = String((route?.distance ?? -1) / 1000)
            time = String(format: "%.2f", (route?.expectedTravelTime ?? -1) / 60)
        } catch {
            print("error with directions")
        }
    }
}


//40.740979140527834, -73.98966672823792


//40.73130329269146, -73.99705445144045
