import SwiftUI
import MapKit
struct MainView: View {
    @ObservedObject var vm = MainViewModel()
    @State var cameraFrom: MapCameraPosition = .automatic
    @State var cameraTo: MapCameraPosition = .automatic
    @FocusState var showSourceKeyboard: Bool
    @FocusState var showDestinationKeyboard: Bool
    @State private var locationService = LocationService(completer: .init())
    var body: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink {
                    Navigation()
                        .environmentObject(vm)
                } label: {
                    Text("Navigate")
                        .foregroundStyle(vm.errorText != nil  ? Color.clear : Color.white)
                        .padding(.horizontal)
                        .padding(.vertical, 2)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundStyle(vm.errorText != nil ? Color.clear : Color.blue)
                        }
                }

            }
            MapWithSearch(ownCoordinate: $vm.from, isMapShowing: $vm.isShowingMapFrom, locationData: $vm.sourceTextfield, camera: $cameraFrom) {
                Task {
                    vm.searchResults = (try? await locationService.search(with: vm.sourceTextfield)) ?? []
                    if let location = vm.searchResults.first?.location {
                        vm.from = location
                        print("\(location)")
                        vm.isShowingMapFrom = true
                        showDestinationKeyboard = false
                        cameraFrom = vm.updateCamera(location: vm.from)
                        do {
                            try await vm.calcualteDistance()
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            .environmentObject(locationService)
            HStack {
                TextField("From", text: $vm.sourceTextfield, axis: .vertical)
                    .font(Font.system(size: 21, weight: .medium))
                    .frame(minWidth: 10, maxWidth: 80, minHeight: 20, maxHeight: 100)
                    .focused($showSourceKeyboard)
                    .fixedSize(horizontal: false, vertical: true)
                    .onSubmit {
                        showSourceKeyboard = false
                    }
                    
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        Info(image: $vm.timeImage, text: $vm.time, errorText: .constant(nil)) {}
                        HStack {
                            let circleCount = Int(geo.size.width / 12)
                            ForEach(0..<circleCount, id: \.self) { _ in
                                Circle()
                                    .frame(width: 3)
                            }
                            Image(systemName: "arrow.right")
                        }
                        Info(image: $vm.transportationImage, text: $vm.distance, errorText: $vm.errorText) {
                            ForEach(0..<vm.transportationTypes.count, id: \.self) { index in
                                let transport = vm.transportationTypes[index]
                                Button {
                                    Task {
                                        await vm.changeTransportation(type: transport.name)
                                        vm.isShowingMapTo = true
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
                TextField("To", text: $vm.destinationTextfield, axis: .vertical)
                    .frame(minWidth: 10, maxWidth: 80)
                    .font(Font.system(size: 21, weight: .medium))
                    .focused($showDestinationKeyboard)
                    .onSubmit {
                        showDestinationKeyboard = false
                    }
            }
            .frame(height: 100)
            .padding(.horizontal)
            MapWithSearch(ownCoordinate: $vm.to, isMapShowing: $vm.isShowingMapTo, locationData: $vm.destinationTextfield, camera: $cameraTo) {
                Task {
                    vm.searchResults = (try? await locationService.search(with: vm.destinationTextfield)) ?? []
                    if let location = vm.searchResults.first?.location {
                        vm.to = location
                        vm.isShowingMapTo = true
                        showSourceKeyboard = false
                        cameraTo = vm.updateCamera(location: vm.to)
                        do {
                            try await vm.calcualteDistance()
                        } catch {
                            print(error)
                        }
                            
                        
                    }
                }
            }
            .environmentObject(locationService)
            .ignoresSafeArea()
        }
        .onAppear {
            cameraFrom = vm.updateCamera(location: vm.from)
            cameraTo = vm.updateCamera(location: vm.to)
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
            vm.isShowingMapFrom = false
        }
        .onChange(of: vm.destinationTextfield) { oldValue, newValue in
            locationService.update(queryFragment: newValue)
            vm.isShowingMapTo = false

        }
    }
}
#Preview {
    MainView()
}
