//
//  ReminderItem.swift
//  HackMTY2025
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//


import SwiftUI
struct ReminderItem: View {
    let reminder: Reminder
    @State private var totalSavings = 5029
    @State private var boxColor = midBlue
    var body: some View {
        HStack{
            VStack (alignment:.leading){
                Text("$\(reminder.amount)")
                    .bold()
                    .font(.title2)
                
                HStack(){
                    Text("\(reminder.start, format: .dateTime.month().day().year())")
                    Spacer()
                    Text("\(reminder.end, format: .dateTime.month().day().year())")
                }
            }
            .padding()
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(reminder.isReminderPassed(by: totalSavings) ? Color.green : coolRed, lineWidth: 2)
            )
            
            
            
        }
        .padding(.horizontal,30)
    }
}
#Preview{
    ReminderItem(reminder: Reminder(amount: 2000, start: Date.now, end: Date.now))
}
