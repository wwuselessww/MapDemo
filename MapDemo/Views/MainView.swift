import SwiftUI
import MapKit
struct MainView: View {
    @ObservedObject var vm = MainViewModel()
    @State var cameraFrom: MapCameraPosition = .automatic
    @State var cameraTo: MapCameraPosition = .automatic
    var oneOfMultiple: [String] {
        [
            vm.distance,
            vm.time,
            vm.transportationImage
        ]
    }
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
                        Info(image: $vm.timeImage, text: $vm.time) {}
                        HStack {
                            let circleCount = Int(geo.size.width / 12)
                            ForEach(0..<circleCount, id: \.self) { _ in
                                Circle()
                                    .frame(width: 3)
                            }
                            Image(systemName: "arrow.right")
                        }
                        Info(image: $vm.transportationImage, text: $vm.distance) {
                            ForEach(0..<vm.transportationTypes.count, id: \.self) { index in
                                let transport = vm.transportationTypes[index]
                                Button {
                                    Task {
                                        await vm.changeTransportation(type: transport.name)
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: transport.imageStr)
                                        Text(transport.name.rawValue)
                                    }
                                }
                                
                            }
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
            
        }
        .onChange(of: vm.transportationImage) { oldValue, newValue in
            Task {
                do {
                    try await vm.calcualteDistance()
                } catch {
                    print("error in view")
                }
            }
            
        }
    }
}
#Preview {
    MainView()
}
