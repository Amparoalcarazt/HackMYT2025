//
//  APIKey.swift
//  HackMTY2025
//
//  Created by FurryVale on 10/26/25.
//


import Foundation   // Required for Bundle and NSDictionary

enum APIKey {
    // Access Gemini API key from GenerativeAI-Info.plist
    static var `default`: String {
        guard let filePath = Bundle.main.path(forResource: "GenAI-Info", ofType: "plist") else {
            fatalError("Could not find 'GenAI-Info.plist' in your project.")
        }

        guard let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist["API_KEY"] as? String
        else {
            fatalError("Could not find 'API_KEY' key in 'GenAI-Info.plist'.")
        }

        if value.starts(with: "_") {
            fatalError("Invalid Gemini API key. Check MLH dashboard or Google AI console.")
        }

        return value
    }
}
