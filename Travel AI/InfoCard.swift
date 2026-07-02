//
//  InfoCard.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

struct InfoCard: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    InfoCard(
        title: "Place Name",
        value: "Eiffel Tower",
        systemImage: "building.2"
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
