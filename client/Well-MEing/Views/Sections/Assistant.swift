import Foundation
import SwiftUI

struct Assistant: View {
    @State private var showModal = false

    var body: some View {
        // Generate report button
        HButton(text: "Request report", textColor: .accentColor) {
            print("report please")
        }
        .padding()
        .bold()
        .font(.title3)

        // Show reports title
        Text("Reports")
            .font(.title2)
            .bold()
            .padding(.horizontal)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}
