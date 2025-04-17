import SwiftUI
import MapKit

class MainViewModel: ObservableObject {
    @Published var from: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.740979140527834, longitude: -73.98966672823792)
    
    @Published var to: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.73130329269146, longitude: -73.99705445144045)
    @Published var time: String = ""
    @Published var distance: String = ""
    @Published var transportationType: MKDirectionsTransportType = .automobile
    @Published var transportationImage: String = "car"
    @Published var timeImage: String = "clock"
    
    let transportationTypes: [TransportationModel] = [.init(name: .car, imageStr: "car"), .init(name: .transit, imageStr: "bus"), .init(name: .walking, imageStr: "figure.walk")]
    
    func calcualteDistance() async throws -> Bool{
        print("calcualte")
        let fromMarker = MKPlacemark(coordinate: from)
        let toMarker = MKPlacemark(coordinate: to)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: fromMarker)
        request.destination = MKMapItem(placemark: toMarker)
        request.transportType = transportationType
        
        let directions = MKDirections(request: request)
        do {
           let results = try await directions.calculate()
            let route = results.routes.first
            withAnimation {
                distance = String(format: "%.1f" ,((route?.distance ?? -1) / 1000)) + " km"
                time = String(format: "%.2f", (route?.expectedTravelTime ?? -1) / 60) + " m"
            }
            return true
        } catch let error{
            print("\(error.localizedDescription)\n")
            print(error)
            return false
        }
    }
    
    func changeTransportation(type transport: Transport) async {
        switch transport {
        case .car:
            transportationType = .automobile
            transportationImage = "car"
        case .transit:
            transportationType = .transit
            transportationImage = "bus"
        case .walking:
            transportationType = .walking
            transportationImage = "figure.walk"
        }
        
        do {
            try await calcualteDistance()
        } catch {
            print("no transport here")
        }
        
        
    }
}


//40.740979140527834, -73.98966672823792


//40.73130329269146, -73.99705445144045

