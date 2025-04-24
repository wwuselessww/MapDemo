import SwiftUI
import MapKit

struct Navigation: View {
    @EnvironmentObject var mainVm: MainViewModel
    @ObservedObject var vm = NavigationViewModel()
    var body: some View {
        VStack {
            if let route = mainVm.route {
                Map {
                    Marker(mainVm.sourceTextfield, coordinate: mainVm.from)
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                    Marker(mainVm.destinationTextfield, coordinate: mainVm.to)
                }
            } else {
                RoundedRectangle(cornerRadius: 2)
                    .foregroundStyle(.orange)
            }
            
            
        }
    }
}
#Preview {
    Navigation()
        .environmentObject(MainViewModel())
}
