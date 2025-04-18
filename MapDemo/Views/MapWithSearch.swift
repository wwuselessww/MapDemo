import SwiftUI
import MapKit

struct MapWithSearch: View {
    
    @Binding var ownCoordinate: CLLocationCoordinate2D
    @Binding var isMapShowing: Bool
    @Binding var locationData: String
    @State var camera: MapCameraPosition = .automatic
    
    @EnvironmentObject var locationService: LocationService
    var content: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
            List {
                ForEach(locationService.completions) { searchResult in
                    Button {
                        content()
                        locationData = searchResult.title
                    } label: {
                        VStack(alignment: .leading) {
                            Text(searchResult.title)
                                .font(.title3)
                            Text(searchResult.subtitle)
                                .font(.caption)
                        }
                        .foregroundStyle(.white)
                    }

                }
            }
            
            if isMapShowing {
                Map(position: $camera) {
                    Marker("Marker", coordinate: ownCoordinate)
                }
            }

        }
        .onAppear {
//            camera = .region(MKCoordinateRegion(center: ownCoordinate, latitudinalMeters: 200, longitudinalMeters: 200))
        }
        .onChange(of: locationData) { oldValue, newValue in
//            camera = .region(MKCoordinateRegion(center: ownCoordinate, latitudinalMeters: 200, longitudinalMeters: 200))
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
        
    }
}

#Preview {
    @Previewable @State var locationService = LocationService(completer: .init())
    @Previewable @State var text: String = ""
    @Previewable @State var isMapShowing: Bool = true
    
    @Previewable @State var source: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.740979140527834, longitude: -73.98966672823792)
    @Previewable @State var destination: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 40.73130329269146, longitude: -73.99705445144045)
    @Previewable @State var searchResults = [SearchResults]()
    @Previewable @State var location: String = ""
    
    VStack {
        TextField("From", text: $text)
            .onChange(of: text) { oldValue, newValue in
                isMapShowing = false
            }
        
        
        MapWithSearch(ownCoordinate: $source, isMapShowing: $isMapShowing, locationData: $location) {
            Task {
                searchResults = (try? await locationService.search(with: text)) ?? []
                if let location = searchResults.first?.location {
                    destination = location
//                    vm.isSearching.toggle()
                    print("destination \(destination)")
                }
                isMapShowing = true
                
            }
        }
        .environmentObject(locationService)
            .frame(width: 400, height: 400)
        
        
        
        
        Button {
            isMapShowing = true
            text = ""
        } label: {
            Text("Revert back")
        }
    }
}


