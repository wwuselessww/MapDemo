import SwiftUI
import MapKit

struct Navigation: View {
    var source: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.740979140527834, longitude: -73.98966672823792)
    var destination: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.73130329269146, longitude: -73.99705445144045)
    var destination2: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.73130329269146, longitude: -73.98705445144045)
    @ObservedObject var vm = NavigationViewModel()
    var body: some View {
        VStack {
            if let route = vm.route {
                Map {
                    Marker(item: MKMapItem(placemark: .init(coordinate: source)))
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                    Marker(item: MKMapItem(placemark: .init(coordinate: destination2)))
                }
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .foregroundStyle(.orange)
            }
            
            
        }
        .onAppear {
            Task {
                await vm.route = vm.setRoute(from: source, to: destination2)
            }
        }
    }
}
#Preview {
    Navigation()
}
