//
//  RemindersView.swift
//  HackMTY2025
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//
import SwiftUI
import SwiftData

struct RemindersList: View {
    @Query(sort: \Reminder.start)private var reminders: [Reminder]
    @Environment(\.modelContext) private var context
    @State private var newAmount = 0
    @State private var newDate = Date.now
    
    var body: some View {
        ScrollView {
            ForEach(reminders) { reminder in
                VStack(spacing: 10){
                    ReminderItem(reminder: reminder)

                    
                }
            }
        }
        .padding()
        
        
        
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .center, spacing: 10) {
                Text("New Reminder")
                    .font(.headline)
                
                
                TextField("Amount", value: $newAmount, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                DatePicker("End Date", selection: $newDate, in: Date.now..., displayedComponents: .date)
                Button("Save") {
                    let newReminder = Reminder(amount: newAmount, start: Date.now, end: newDate)
                    context.insert(newReminder)
                    newDate = .now
                }
                .bold()
                
            }
            .padding()
            .padding(.horizontal, 30)
            .background(.bar)
            .background(midBlue)
        }
    }
}


#Preview {
    RemindersList()
        .modelContainer(for: Reminder.self, inMemory: true)
}
