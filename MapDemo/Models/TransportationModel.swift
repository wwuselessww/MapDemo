import Foundation

struct TransportationModel {
    let name: Transport
    let imageStr: String
}

enum Transport: String {
    case car = "Car"
    case transit = "Transit"
    case walking = "Walking"
}
