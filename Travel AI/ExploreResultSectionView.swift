//
//  ExploreResultSectionView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

struct ExploreResultSectionView: View {
    let isLoading: Bool
    let errorMessage: String?
    let recognitionResult: PlaceRecognitionResult?

    var body: some View {
        Group {
            if isLoading {
                VStack(spacing: 14) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Detecting landmark...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .transition(.opacity)
            } else if let errorMessage {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.title3)

                    Text(errorMessage)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .transition(.opacity)
            } else if let recognitionResult {
                ResultCardView(result: recognitionResult)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }
}

#Preview {
    ExploreResultSectionView(
        isLoading: false,
        errorMessage: nil,
        recognitionResult: PlaceRecognitionResult(
            placeName: "Eiffel Tower",
            city: "Paris",
            country: "France",
            confidence: 95,
            quickFacts: [
                "Stands 330 meters tall including its antenna.",
                "Built for the 1889 World's Fair in Paris.",
                "One of the most visited paid monuments in the world."
            ],
            story: "Notice how the iron lattice opens wider at the base and tightens as it rises. That lattice was meant for a temporary fairground attraction, yet it stayed because the city could not imagine the skyline without it.",
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
