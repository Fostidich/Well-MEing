import SwiftUI

struct RatingInputType: View {
    let config: [String: Any]?
    let completion: (Any?) -> Void
    var initialValue: Any?
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
                    .onChange(of: rating) {
                        completion(rating)
                    }
            }
        }
        .onAppear {
            rating = initialValue as? Int ?? 0
        }
    }
    
}
