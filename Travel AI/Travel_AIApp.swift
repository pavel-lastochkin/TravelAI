//
//  Travel_AIApp.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

@main
struct Travel_AIApp: App {
    @StateObject private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ExplorePlaceView()
            }
            .environmentObject(appSettings)
        }
    }
}
