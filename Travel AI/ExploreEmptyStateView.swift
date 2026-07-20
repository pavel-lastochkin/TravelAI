//
//  ExploreEmptyStateView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

struct ExploreEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.magnifyingglass")
                .font(.system(size: 56))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)

            Text("Discover any place")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Take a photo or choose one from your library to instantly identify landmarks, attractions and interesting places.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Discover any place. Take a photo or choose one from your library to identify landmarks and attractions.")
    }
}

#Preview {
    ExploreEmptyStateView()
        .background(Color(.systemGroupedBackground))
}
