import SwiftUI


struct DashboardOld: View {
    @State private var showAddHabitModal = false
    @State private var habitToDelete: String = ""
    @State private var habits: [[String: Any]] = []
    @State private var isLoading = true
    //@State private var showAddHistoryModal = false        TODO

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // ➕ Floating "+" Button
            Button(action: {
                showAddHabitModal.toggle()
            }) {
                Image(systemName: "plus")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                    .padding()
            }
            .sheet(isPresented: $showAddHabitModal) {
                AddHabitModal()
            }

            NavigationView {
                Group {
                    if isLoading {
                        ProgressView("Loading habits...")
                    } else if habits.isEmpty {
                        Text("No habits found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    } else {
                        List {
                            ForEach(habits.indices, id: \.self) { index in
                                HabitRow(habit: habits[index])
                            }
                        }
                    }
                }
                .navigationTitle("My Habits")
                .onAppear {
                    loadHabits()
                }
            }

            Spacer()
            
            // ADD HISTORY MODAL            TODO
            
            Spacer()
            
            // Delete habit field
            VStack(alignment: .leading, spacing: 10) {
                TextField("Enter habit name to delete", text: $habitToDelete)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: {
                    deleteHabitByName(habitName: habitToDelete)
                    habitToDelete = "" // optional: clear field
                }) {
                    Text("Delete Habit")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            
        }
    }
    private func loadHabits() {
            fetchHabits { fetchedHabits in
                self.habits = fetchedHabits
                self.isLoading = false
            }
        }
}


struct HabitRow: View {
    let habit: [String: Any]
    var body: some View {
        VStack(alignment: .leading) {
            Text(habit["name"] as? String ?? "Unnamed Habit")
                .font(.headline)
            Text(habit["description"] as? String ?? "")
                
            DashboardItem(content: ((habit["id"] as? String) ?? "No ID", "Add metric"))
        }
        .padding(.vertical, 4)
    }
}

struct DashboardItem: View {
    let content: (String, String)
    @State private var showModal = false

    var body: some View {
        Button(action: {
            showModal.toggle()
        }) {
            ZStack {
                // Button color fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.15))
                    .frame(height: 50)
                
                // Content of the task button
                HStack {
                    //Text(content.0) // Key
                       // .font(.subheadline)
                        //.foregroundColor(.secondary)
                    
                    //Spacer()
                    
                    Text(content.1) // Value
                        .font(.subheadline)
                        .lineLimit(1)
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showModal) {
            TaskModal(habitID: content.0)
        }
    }
}

struct TaskModal: View {
    let habitID: String  // pass this from parent view
    @State private var existingMetrics: [[String: Any]] = []
    @State private var isLoading = true
    @Environment(\.presentationMode) var presentationMode
    
    @State private var fields: [(key: String, value: String)] = [
        ("name", ""),
        ("format", ""),
        ("inputType", "")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Display existing metrics
                    Group {
                        Text("Existing Metrics")
                            .font(.headline)
                            .padding(.top, 8)
                            .foregroundColor(.red)
                        
                        Spacer()
                        
                        if isLoading {
                            ProgressView("Loading metrics...")
                        } else if existingMetrics.isEmpty {
                            Text("No metrics found")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(0..<existingMetrics.count, id: \.self) { index in
                                MetricRow(metric: existingMetrics[index], habitID: habitID)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text("Add New Metric")
                            .font(.headline)
                    }
                    
                    // New metric form fields
                    ForEach(0..<fields.count, id: \.self) { index in
                        HStack {
                            TextField("Key", text: $fields[index].key)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Value", text: $fields[index].value)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    
                    Button(action: {
                        fields.append(("", ""))
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Field")
                        }
                    }
                    .padding(.top)
                    
                    Button(action: saveToDatabase) {
                        HStack {
                            Image(systemName: "tray.and.arrow.down.fill")
                            Text("Save")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("Habit Metrics", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                loadMetrics()
            }
        }
    }
    
    private func loadMetrics() {
        isLoading = true
        
        fetchMetrics(for: habitID) { metrics in
            DispatchQueue.main.async {
                self.existingMetrics = metrics
                self.isLoading = false
            }
        }
    }
    
    private func saveToDatabase() {
        var metricDetails: [String: Any] = [:]
        for field in fields {
            guard !field.key.isEmpty, !field.value.isEmpty else { continue }
            metricDetails[field.key] = field.value
        }
        
        insertMetric(newHabitID: habitID, metricDetails: metricDetails)
        presentationMode.wrappedValue.dismiss()
    }
}

// Helper view to display each metric
struct MetricRow: View {
    let metric: [String: Any]
    let habitID: String
    @Environment(\.presentationMode) var presentationMode
        
    @State private var numberInput: String = ""
    @State private var satisfaction: String = ""
    @State private var otherInfo: String = ""
    
    var body: some View {
        if let name = metric["name"] as? String {
            Text(name)
                .font(.headline)
                .padding(.bottom, 2)
        }

        ForEach(Array(metric.keys.sorted().filter { $0 != "name" }), id: \.self) { key in
            if let value = metric[key] {
                HStack {
                    Text(key)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(String(describing: value))")
                        .font(.caption)
                }
            }
        }
        
        NavigationView {
            Form {
                Section(header: Text("Metrics")) {
                    TextField("Number", text: $numberInput)
                        .keyboardType(.numberPad)
                    
                    TextField("Satisfaction", text: $satisfaction)
                    
                    TextField("Other Information", text: $otherInfo)
                }
                
                Section {
                    Button(action: saveHistory) {
                        HStack {
                            Image(systemName: "tray.and.arrow.down.fill")
                            Text("Save History")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
            }
            .navigationBarTitle("Add History", displayMode: .inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveHistory() {
        var historyDetails: [String: Any] = [:]
        historyDetails["number"] = Int(numberInput) ?? 0
        historyDetails["satisfaction"] = satisfaction
        historyDetails["otherInfo"] = otherInfo
        
        // Call your database function
        insertHistory(newHabitID: habitID, historyDetails: historyDetails)
        
        presentationMode.wrappedValue.dismiss() // Dismiss the modal
    }
}

struct DashboardButtonContent: View {
    let content: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task title
            Text(content)
                .font(.title3)
                .bold()
        }
    }
}

/*
struct DashboardItem: View {
    let content: (String, String)
    
    @State private var showModal = false

    var body: some View {
        Button(action: {
            showModal.toggle()
        }) {
            ZStack {
                // Button color fill
                
                RoundedRectangle(cornerRadius: 10)
                

                // Content of the task button
                DashboardButtonContent(content: content.1)
                    .padding()
            }
        }
        .sheet(isPresented: $showModal) {
            TaskModal(content: content)
        }
    }
}

struct DashboardButtonContent: View {
    let content: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task title
            Text(content)
                .font(.title3)
                .bold()
                
        }
    }
}

struct TaskModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var value: Double = 10
    @State private var submitted: Double? = nil
    let content: (title: String, description: String)

    var body: some View {
        NavigationStack {
            VStack {
                // Modal content
                Text(content.description)
                    .font(.title3)
                    .padding()
                    .frame(
                        maxWidth: .infinity, maxHeight: .infinity,
                        alignment: .topLeading
                    )
                   

                if let submitted = submitted {
                    Text("Submitted: \(Int(submitted))")
                        .padding()
                }
                Slider(value: $value, in: 0...20)
                    .padding()

                Button(action: {
                    //submitted = value
                    insertHistory(newHabit: content.title, historyDetails: ["duration": "01:30:00", // adds also timestamp
                                                                            "distance": 13.4,
                                                                            "satisfaction": 4])
                    dismiss()
                }) {
                    Text("Log \(Int(value))")
                        .bold()
                        .font(.title3)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.secondary.opacity(0.20))
                        )
                }
                .padding(.bottom)
            }
            .navigationBarTitle(
                content.title,
                displayMode: .inline
            )  // title in center
            .navigationBarItems(
                leading: Button("Back") {
                    dismiss()  // dismiss modal
                })
        }
    }
}
 
 */

struct DashboardButtonAddHabit: View {
    let title = "+"
    let content: (title: String, description: String)
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Task title
            Text(content.title)
                .font(.title3)
                .bold()
                .foregroundColor(color)
        }
    }
}

struct DeleteHabitField: View {
    @State private var habitToDelete: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter habit name to delete", text: $habitToDelete)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                deleteHabitByName(habitName: habitToDelete)
                habitToDelete = "" // clear after deletion
            }) {
                Text("Delete Habit")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
    }
}


struct AddHabitModal: View {
    @Environment(\.dismiss) var dismiss
    @State private var habitName: String = ""
    @State private var habitDescription: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // Habit Name Input
                TextField("Habit name...", text: $habitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Habit Description Input
                TextField("Habit description...", text: $habitDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                // Save Button
                Button(action: {
                    insertHabit(newHabit: habitName, habitDetails: ["description": habitDescription])
                    dismiss()
                }) {
                    Text("Save Habit")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .padding()
            .navigationTitle("New Habit")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}
