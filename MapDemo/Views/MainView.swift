import SwiftUI
import MapKit
struct MainView: View {
    @ObservedObject var vm = MainViewModel()
    @State var cameraFrom: MapCameraPosition = .automatic
    @State var cameraTo: MapCameraPosition = .automatic
    @State private var locationService = LocationService(completer: .init())
    var body: some View {
        VStack {
            Map(position: $cameraFrom) {
                Marker("tower", coordinate: vm.from)
            }
            
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .ignoresSafeArea()
            HStack {
                TextField("From", text: $vm.sourceTextfield)
                    .frame(minWidth: 10, maxWidth: 80)
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
                TextField("To", text: $vm.destinationTextfield)
                    .frame(minWidth: 10, maxWidth: 80)
                    .font(Font.system(size: 21, weight: .medium))
                
            }
            .frame(height: 100)
            .padding(.horizontal)
            //            Map(position: $cameraTo) {
            //                Marker("heh", coordinate: vm.to)
            //            }
            //            .clipShape(RoundedRectangle(cornerRadius: 25))
            //            .ignoresSafeArea()
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .background(content: {
                        Color.red
                    })
                    .ignoresSafeArea()
                List {
                    ForEach(locationService.completions) { completion in
                        Button {
                            print(completion.title)
                            Task {
                                vm.searchResults = (try? await locationService.search(with: vm.sourceTextfield)) ?? []
//                                print(vm.searchResults)
                                if let location = vm.searchResults.first?.location {
                                    vm.from = location
                                    vm.isSearching.toggle()
                                    print("\(location)")
                                }
                                
                            }
                        } label: {
                            VStack(alignment: .leading) {
                                Text(completion.title)
                                    .font(.title3)
                                Text(completion.subtitle)
                                    .font(.caption)
//                                if let url = completion.url {
//                                    Link(destination: url) {
//                                        Text(url.absoluteString)
//                                    }
//                                }
                            }
                            .foregroundStyle(.white)
                        }
                        
                    }
                }
                //                .foregroundStyle(.clear)
            }
        }
        .onAppear {
            cameraFrom = .region(MKCoordinateRegion(center: vm.from, latitudinalMeters: 200, longitudinalMeters: 200))
            cameraTo = .region(MKCoordinateRegion(center: vm.to, latitudinalMeters: 200, longitudinalMeters: 200))
            
        }
        .onChange(of: vm.isSearching) { oldValue, newValue in
            cameraFrom = .region(MKCoordinateRegion(center: vm.from, latitudinalMeters: 200, longitudinalMeters: 200))
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
        .onChange(of: vm.sourceTextfield) { oldValue, newValue in
            locationService.update(queryFragment: newValue)
        }
    }
}
#Preview {
    MainView()
}
