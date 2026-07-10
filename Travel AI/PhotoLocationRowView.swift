//
//  PhotoLocationRowView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

struct PhotoLocationRowView: View {
    let context: PhotoLocationContext

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text(context.sourceLabel)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(context.coordinateSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "location")
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Open in Maps") {
                context.openInMaps()
            }
            .font(.caption)
            .buttonStyle(.bordered)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    PhotoLocationRowView(
        context: PhotoLocationContext(
            latitude: 48.8584,
            longitude: 2.2945,
            source: .photoMetadata
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
