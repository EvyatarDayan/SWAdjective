//
//  SwedisherApp.swift
//  Swedisher
//
//  Created by EVYATAR DAYAN on 2026-01-28.
//

import SwiftUI

@main
struct SwedisherApp: App {
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
