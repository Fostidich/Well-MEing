import SwiftUI

struct RatingInputSelector: View {
    @Binding var config: [String: Any]
    var resetTrigger: Bool?
    @State private var rating: Int = 0

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 22)
                    .foregroundColor(.accentColor)
                    .onTapGesture {
                        rating = i
                    }
            }
        }
        .onAppear(perform: reset)
        .onChange(of: resetTrigger, reset)
    }
    
    private func reset() {
        rating = 0
    }
}
