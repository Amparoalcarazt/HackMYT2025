//
//  CustomCategory.swift
//  HackMTY2025
//

import SwiftUI

// MARK: - Custom Category Model
struct CustomCategory: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let icon: String
    let colorHex: String
    
    init(id: String, name: String, icon: String, color: Color) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = color.toHex() ?? "#007AFF"
    }
    
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    // Equatable conformance
    static func == (lhs: CustomCategory, rhs: CustomCategory) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Color Extension
extension Color {
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
    
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}
