import SwiftUI

struct Info<Content: View>: View {
    @Binding var image: String
    @Binding var text: String
    let content: Content
    init(image: Binding<String>, text: Binding<String>, @ViewBuilder _ content: () -> Content) {
        self._image = image
        self._text = text
        self.content = content()
     
     
    }
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 10, maxWidth: 20, minHeight: 15, maxHeight: 20)
                .contextMenu {
                    VStack {
                        content
                    }
                }
            Text(text)
                .contentTransition(.numericText())
        }
    }
}
#Preview {
    Info(image: .constant("house"), text: .constant("test m")) {
        Text("ssa")
        Text("ssa")
        Text("ssa")
    }
}
