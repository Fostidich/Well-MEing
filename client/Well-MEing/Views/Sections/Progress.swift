import SwiftUI

struct Progress: View {
    @State private var showModal: Bool = false
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        CalendarView { _, date in
            selectedDate = date
            showModal.toggle()
        }
        .sheet(isPresented: $showModal) {
            Modal(title: selectedDate.fancyDateString, dismissButton: .cancel) {
                PastSubmissionsModalContent(date: selectedDate)
            }
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: showModal)
        
        // Show statistics title
        Text("Statistics")
            .font(.title2)
            .bold()
            .padding(.horizontal)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)

    }
    
}
