import SwiftUI
import MapKit

class NavigationViewModel: ObservableObject {
    @Published var route: MKRoute?
    
    func setRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, transportationType: MKDirectionsTransportType) async -> MKRoute? {
        var req = MKDirections.Request()
        req.source = MKMapItem(placemark: .init(coordinate: source))
        req.destination = MKMapItem(placemark: .init(coordinate: destination))
        req.transportType = .automobile
        let directions = MKDirections(request: req)
        var res: MKDirections.Response?
        
        do {
            res = try await directions.calculate()
            print("from", source)
            print("to", destination)
            print("res is good ", res)
            return res?.routes.first
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
}
