//
//  ExplorePhotoActionsView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import PhotosUI
import SwiftUI

struct ExplorePhotoActionsView: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    let isLoading: Bool
    let isCameraAvailable: Bool
    let onCameraTap: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    secondaryActionLabel(title: "Gallery", systemImage: "photo.on.rectangle")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isLoading)

                Button(action: onCameraTap) {
                    secondaryActionLabel(title: "Camera", systemImage: "camera")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isLoading || !isCameraAvailable)
            }

            if !isCameraAvailable {
                Text("Camera is not available on this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func secondaryActionLabel(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedPhoto: PhotosPickerItem?

        var body: some View {
            ExplorePhotoActionsView(
                selectedPhoto: $selectedPhoto,
                isLoading: false,
                isCameraAvailable: true,
                onCameraTap: {}
            )
            .padding()
            .background(Color(.systemGroupedBackground))
        }
    }

    return PreviewWrapper()
}
