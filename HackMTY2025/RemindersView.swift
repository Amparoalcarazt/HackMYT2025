//
//  RemindersView.swift
//  HackMTY2025
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//

import SwiftUI
import SwiftData
import TipKit

// TipKit!! 
struct CreateReminderTip: Tip {
    var title: Text {
        Text("Set Your First Goal")
    }
    
    var message: Text? {
        Text("Create a savings reminder to track your progress")
    }
    
    var image: Image? {
        Image(systemName: "target")
    }
}

struct RemindersView: View {
    @Query(sort: \Reminder.start) private var reminders: [Reminder]
    @Environment(\.modelContext) private var context
    @State private var newAmount = 0
    @State private var newDate = Date.now
    
    // TipKit initializze the tip
    private let createReminderTip = CreateReminderTip()
    
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
                    
                    // TipKit showingg tip only when empty
                    TipView(createReminderTip)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
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
                    
                    // Part of tipkit too, invalidate tip after first reminder
                    createReminderTip.invalidate(reason: .actionPerformed)
                }
                .bold()
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .padding(.horizontal, 30)
            .background(.bar)
            .background(midBlue)
        }
        .onAppear {
            // TipKit: Configure tips (call once in app lifecycle, typically in App file)
            // try? Tips.configure([.displayFrequency(.immediate), .datastoreLocation(.applicationDefault)])
        }
    }
}

#Preview {
    RemindersView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
