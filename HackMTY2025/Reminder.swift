//
//  Reminder.swift
//  HackMTY2025
//
//  Created by Amparo Alcaraz Tonella on 25/10/25.
//


import Foundation
import SwiftData

@Model
class Reminder {
    var id: UUID
    var amount: Int
    var start: Date
    var end: Date
    
    
    init(id: UUID = UUID(), amount: Int, start: Date, end: Date) {
        self.id = id
        self.amount = amount
        self.start = start
        self.end = end
    }
    
    func isReminderPassed(by savings: Int) -> Bool {
        return savings > amount
    }
}
