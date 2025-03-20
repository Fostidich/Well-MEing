import SwiftUI

struct DashboardPage: View {

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(MockData.items, id: \.title) { item in
                    DashboardItem(text: item.title, action: item.action)
                }
            }
            .padding(.top, 80)
            .padding(.bottom, 70)
            .padding(.horizontal)
        }
    }
}

struct DashboardItem: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.20))
                .frame(height: 200)
                .padding(5)
                .overlay(Text(text).font(.title))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
