import SwiftUI

struct Info<Content: View>: View {
    @Binding var image: String
    @Binding var text: String
    @Binding var errorText: String?
    let content: Content
    init(image: Binding<String>, text: Binding<String>, errorText: Binding<String?>, @ViewBuilder _ content: () -> Content) {
        self._image = image
        self._text = text
        self.content = content()
        self._errorText = errorText
     
    }
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 10, maxWidth: 20, minHeight: 15, maxHeight: 20)
                .foregroundStyle(errorText != nil  ? .red : Color(.text))
                .contextMenu {
                    VStack {
                        content
                    }
                }
            if let errorText = errorText {
                Text(errorText)
                    .lineLimit(3)
                    .foregroundStyle(.red)
                    .contentTransition(.numericText())
            } else {
                Text(text)
                    .contentTransition(.numericText())
            }
        }
    }
}
#Preview {
    Info(image: .constant("house"), text: .constant("test m"), errorText: .constant("error here")) {
        Text("ssa")
        Text("ssa")
        Text("ssa")
    }
}
