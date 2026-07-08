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
    @AppStorage(WelcomeStorage.skipWelcomeKey) private var skipWelcomeScreen = false
    @State private var showMainApp = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if skipWelcomeScreen || showMainApp {
                    ContentView()
                } else {
                    LogoView(onStart: { showMainApp = true })
                }
            }
            .preferredColorScheme(darkModeEnabled ? .dark : .light)
        }
    }
}
