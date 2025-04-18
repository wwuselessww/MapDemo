import Foundation
import MapKit

class LocationService: NSObject, MKLocalSearchCompleterDelegate, ObservableObject {
    private let completer: MKLocalSearchCompleter
    
    var completions = [SearchCompletions]()
    
    init(completer: MKLocalSearchCompleter) {
        self.completer = completer
        super.init()
        self.completer.delegate = self
        
    }
    
    func update(queryFragment: String) {
        completer.resultTypes = .address
        completer.queryFragment = queryFragment
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map { completion in
//                .init(title: $0.title, subtitle: $0.subtitle)
            let mapItem = completion.value(forKey: "_mapItem") as? MKMapItem
            
            return .init(title: completion.title, subtitle: completion.subtitle, url: mapItem?.url)
            
        }
    }
    
    func search(with query: String, coordinate: CLLocationCoordinate2D? = nil) async throws -> [SearchResults] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .address
        
        if let coordinate {
            request.region = .init(.init(origin: .init(coordinate), size: .init(width: 1, height: 1)))
        }
        
        let search = MKLocalSearch(request: request)
        
        let response = try await search.start()
        
        return response.mapItems.compactMap { mapItem in
            guard let location = mapItem.placemark.location?.coordinate else {return nil}
            
            return .init(location: location)
        }
    }
    
    
}

struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    var url: URL?
}


struct SearchResults: Identifiable, Hashable {
    static func == (lhs: SearchResults, rhs: SearchResults) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    let location: CLLocationCoordinate2D
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
