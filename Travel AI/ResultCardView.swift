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

            Text(result.description)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                Label("Did you know?", systemImage: "lightbulb.fill")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(result.interestingFact)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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
            description: "An iconic iron lattice tower and symbol of Paris, offering panoramic views from its observation decks.",
            interestingFact: "It was built for the 1889 World's Fair and was originally intended to be temporary."
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
