import SwiftUI
import MapKit
struct MainView: View {
    @ObservedObject var vm = MainViewModel()
    @State var cameraFrom: MapCameraPosition = .automatic
    @State var cameraTo: MapCameraPosition = .automatic
    var body: some View {
        VStack {
            Map(position: $cameraFrom) {
                Marker("tower", coordinate: vm.from)
            }
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .ignoresSafeArea()
            HStack {
                Text ("Berlin")
                    .font(Font.system(size: 21, weight: .medium))
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "clock")
                            Text("\(vm.time) m")
                                .bold()
                        }
                        HStack {
                            let circleCount = Int(geo.size.width / 12)
                            ForEach(0..<circleCount, id: \.self) { _ in
                                Circle()
                                    .frame(width: 3)
                            }
                            Image(systemName: "arrow.right")
                        }
                        
                        HStack {
                            Image(systemName: "car")
                            Text("\(vm.distance) km")
                            
                        }
                        Spacer()
                    }
                    .frame(minWidth: 10, maxWidth: .infinity)
                }
                Text ("London")
                    .font(Font.system(size: 21, weight: .medium))
                
            }
            .frame(height: 100)
            .padding(.horizontal)
            Map(position: $cameraTo) {
                Marker("heh", coordinate: vm.to)
            }
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .ignoresSafeArea()
        }
        .onAppear {
            cameraFrom = .region(MKCoordinateRegion(center: vm.from, latitudinalMeters: 200, longitudinalMeters: 200))
            cameraTo = .region(MKCoordinateRegion(center: vm.to, latitudinalMeters: 200, longitudinalMeters: 200))
            Task {
                await vm.calcualteDistance()
            }
        }
    }
}
#Preview {
    MainView()
}
