//
//  ExplorePhotoPreviewCard.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import SwiftUI

struct ExplorePhotoPreviewCard: View {
    let image: UIImage

    private let previewHeight: CGFloat = 300
    private let cornerRadius: CGFloat = 16

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: previewHeight)
            .overlay {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
            }
            .accessibilityLabel("Selected photo preview")
    }
}

#Preview {
    ExplorePhotoPreviewCard(image: UIImage(systemName: "photo")!)
        .padding()
        .background(Color(.systemGroupedBackground))
}
