//
//  ExplorePlaceView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import PhotosUI
import SwiftUI

struct ExplorePlaceView: View {
    @State private var placeName = ""
    @State private var response = "AI response will appear here."
    @State private var isLoading = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var previewImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Text("Choose Photo")
            }
            .buttonStyle(.bordered)
            .disabled(isLoading)

            TextField("Place name", text: $placeName)
                .textFieldStyle(.roundedBorder)
                .disabled(isLoading)

            Button("Ask AI") {
                askAI()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Text(isLoading ? "Thinking..." : response)
                .foregroundStyle(isLoading ? .primary : .secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                guard let newItem else {
                    previewImage = nil
                    return
                }
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    previewImage = image
                } else {
                    previewImage = nil
                }
            }
        }
    }

    private func askAI() {
        let name = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        isLoading = true
        Task {
            let result = await askGemini(place: name)
            response = result
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        ExplorePlaceView()
    }
}
