import SwiftUI
import MapKit

struct MapWithSearch: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var ownCoordinate: CLLocationCoordinate2D
    @Binding var isMapShowing: Bool
    @Binding var locationData: String
    @Binding var camera: MapCameraPosition
    
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
                                .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
                            Text(searchResult.subtitle)
                                .font(.caption)
                                .foregroundStyle(colorScheme == .light ? Color.black : Color.white)
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
    @Previewable @State var camera: MapCameraPosition = .automatic
    VStack {
        TextField("From", text: $text)
            .onChange(of: text) { oldValue, newValue in
                isMapShowing = false
            }
        
        
        MapWithSearch(ownCoordinate: $source, isMapShowing: $isMapShowing, locationData: $location, camera: $camera) {
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


