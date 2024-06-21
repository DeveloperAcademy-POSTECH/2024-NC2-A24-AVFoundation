//
//  NC2_WeDrewApp.swift
//  NC2-WeDrew
//
//  Created by LDW on 6/16/24.
//

import SwiftUI
import SwiftData

@main
struct NC2_WeDrewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Reels.self])
    }
}
