//
//  PlaceRecognitionResultView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

struct PlaceRecognitionResultView: View {
    let result: PlaceRecognitionResult

    var body: some View {
        VStack(spacing: 12) {
            InfoCard(
                title: "Place Name",
                value: result.placeName,
                systemImage: "building.2"
            )

            InfoCard(
                title: "Location",
                value: "\(result.city), \(result.country)",
                systemImage: "location"
            )

            InfoCard(
                title: "Confidence",
                value: "\(result.confidence)%",
                systemImage: "checkmark.seal"
            )

            InfoCard(
                title: "Description",
                value: result.description,
                systemImage: "text.alignleft"
            )

            InfoCard(
                title: "Interesting Fact",
                value: result.interestingFact,
                systemImage: "lightbulb"
            )
        }
    }
}

#Preview {
    ScrollView {
        PlaceRecognitionResultView(
            result: PlaceRecognitionResult(
                placeName: "Eiffel Tower",
                city: "Paris",
                country: "France",
                confidence: 95,
                description: "An iconic iron lattice tower and symbol of Paris.",
                interestingFact: "It was built for the 1889 World's Fair."
            )
        )
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
