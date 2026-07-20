//
//  ResultCardView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

struct ResultCardView: View {
    let result: PlaceRecognitionResult

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(result.placeName)
                    .font(.title2)
                    .fontWeight(.bold)

                Label("\(result.city), \(result.country)", systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(result.confidence)% match")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }

            Divider()

            if !result.quickFacts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Facts")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(result.quickFacts, id: \.self) { fact in
                            Label(fact, systemImage: "sparkle")
                                .font(.subheadline)
                                .labelStyle(.titleAndIcon)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            Divider()

            Text(result.story)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    ResultCardView(
        result: PlaceRecognitionResult(
            placeName: "Eiffel Tower",
            city: "Paris",
            country: "France",
            confidence: 95,
            quickFacts: [
                "Stands 330 meters tall including its antenna.",
                "Built for the 1889 World's Fair in Paris.",
                "One of the most visited paid monuments in the world."
            ],
            story: "Notice how the iron lattice opens wider at the base and tightens as it rises. That lattice was meant for a temporary fairground attraction, yet it stayed because the city could not imagine the skyline without it. There is also a quieter story about how close the tower came to being dismantled after the fair ended.",
            followUpQuestions: [
                "Tell me more about its history",
                "How can I visit it?",
                "What else is worth seeing nearby?"
            ]
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
