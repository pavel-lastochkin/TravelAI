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
    @Binding var selectedAction: PlaceExploreAction?
    let placeDetails: PlaceDetailContent?
    let isLoadingDetails: Bool
    let detailsError: String?
    let nearbyPlaces: NearbyPlacesResult?
    let isLoadingNearby: Bool
    let nearbyError: String?
    let onSelectAction: (PlaceExploreAction) -> Void

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
                VStack(alignment: .leading, spacing: 16) {
                    ResultCardView(result: recognitionResult)
                    PlaceExploreActionsView(
                        selectedAction: $selectedAction,
                        details: placeDetails,
                        isLoadingDetails: isLoadingDetails,
                        detailsError: detailsError,
                        nearby: nearbyPlaces,
                        isLoadingNearby: isLoadingNearby,
                        nearbyError: nearbyError,
                        onSelect: onSelectAction
                    )
                }
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
            story: "Notice how the iron lattice opens wider at the base and tightens as it rises. That lattice was meant for a temporary fairground attraction, yet it stayed because the city could not imagine the skyline without it."
        ),
        selectedAction: .constant(.history),
        placeDetails: PlaceDetailContent(
            history: "After the fair, officials nearly dismantled the tower until radio experiments made it too useful to remove.",
            visitInfo: "Start from Champ de Mars and book summit access ahead when crowds are high."
        ),
        isLoadingDetails: false,
        detailsError: nil,
        nearbyPlaces: nil,
        isLoadingNearby: false,
        nearbyError: nil,
        onSelectAction: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
