//
//  ContentView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Travel AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                NavigationLink("Explore place") {
                    ExplorePlaceView()
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
