//
//  PlaceExploreActionsView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 20.07.2026.
//

import SwiftUI

struct PlaceExploreActionsView: View {
    @Binding var selectedAction: PlaceExploreAction?
    let details: PlaceDetailContent?
    let isLoadingDetails: Bool
    let detailsError: String?
    let nearby: NearbyPlacesResult?
    let isLoadingNearby: Bool
    let nearbyError: String?
    let onSelect: (PlaceExploreAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Continue exploring")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            VStack(spacing: 10) {
                ForEach(PlaceExploreAction.allCases) { action in
                    Button {
                        onSelect(action)
                    } label: {
                        Label(action.title, systemImage: action.systemImage)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .opacity(selectedAction == nil || selectedAction == action ? 1 : 0.7)
                }
            }

            if let selectedAction {
                expandedContent(for: selectedAction)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.easeInOut(duration: 0.2), value: selectedAction)
    }

    @ViewBuilder
    private func expandedContent(for action: PlaceExploreAction) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()

            switch action {
            case .history:
                detailSection(
                    text: details?.history,
                    isLoading: isLoadingDetails,
                    error: detailsError,
                    loadingText: "Preparing the story..."
                )
            case .visit:
                detailSection(
                    text: details?.visitInfo,
                    isLoading: isLoadingDetails,
                    error: detailsError,
                    loadingText: "Checking how to visit..."
                )
            case .nearby:
                nearbySection
            }
        }
    }

    @ViewBuilder
    private func detailSection(
        text: String?,
        isLoading: Bool,
        error: String?,
        loadingText: String
    ) -> some View {
        if let text, !text.isEmpty {
            Text(text)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        } else if isLoading {
            loadingRow(text: loadingText)
        } else if let error {
            errorRow(text: error)
        } else {
            loadingRow(text: loadingText)
        }
    }

    @ViewBuilder
    private var nearbySection: some View {
        if let nearby, !nearby.places.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(nearby.places) { place in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                            .font(.headline)
                        if !place.distanceHint.isEmpty {
                            Text(place.distanceHint)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text(place.whyVisit)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        } else if isLoadingNearby {
            loadingRow(text: "Looking for places nearby...")
        } else if let nearbyError {
            errorRow(text: nearbyError)
        } else {
            loadingRow(text: "Looking for places nearby...")
        }
    }

    private func loadingRow(text: String) -> some View {
        HStack(spacing: 10) {
            ProgressView()
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private func errorRow(text: String) -> some View {
        Label(text, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline)
            .foregroundStyle(.orange)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    PlaceExploreActionsView(
        selectedAction: .constant(.history),
        details: PlaceDetailContent(
            history: "After the World's Fair ended, officials nearly dismantled the Eiffel Tower. Radio experiments helped save it.",
            visitInfo: "Most visitors start at the Champ de Mars side. Book summit tickets ahead when possible."
        ),
        isLoadingDetails: false,
        detailsError: nil,
        nearby: NearbyPlacesResult(
            places: [
                NearbyPlaceItem(name: "Champ de Mars", distanceHint: "2 min walk", whyVisit: "Best open lawn for seeing the full tower."),
                NearbyPlaceItem(name: "Trocadéro", distanceHint: "15 min walk", whyVisit: "Classic elevated viewpoint across the river."),
                NearbyPlaceItem(name: "Seine river cruise", distanceHint: "10 min walk", whyVisit: "A calm way to see the tower from the water.")
            ]
        ),
        isLoadingNearby: false,
        nearbyError: nil,
        onSelect: { _ in }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
