//
//  RemindersView.swift
//  HackMTY2025
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//

import SwiftUI
import SwiftData

struct RemindersView: View {
    @Query(sort: \Reminder.start) private var reminders: [Reminder]
    @Environment(\.modelContext) private var context
    @State private var newAmount = 0
    @State private var newDate = Date.now
    
    var body: some View {
        ZStack {
            if reminders.isEmpty {
                // Empty state with background image
                VStack(spacing: 20) {
                    Image(systemName: "bell.slash.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.gray.opacity(0.3))
                    
                    Text("No Reminders")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    
                    Text("Create your first savings goal below")
                        .font(.subheadline)
                        .foregroundStyle(.gray.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.05), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(reminders) { reminder in
                            ReminderItem(reminder: reminder)
                        }
                    }
                    .padding(.top)
                }
                .padding(.horizontal)
            }
        }
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
                    newAmount = 0
                    
                }
                .bold()
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .padding(.horizontal, 30)
            .background(.bar)
            .background(midBlue)
        }
    }
}

#Preview {
    RemindersView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
