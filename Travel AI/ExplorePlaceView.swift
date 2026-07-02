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
    @State private var textResponse = "AI response will appear here."
    @State private var recognitionResult: PlaceRecognitionResult?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var showCamera = false

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                photoSection
                photoActionsSection
                analyzeSection
                searchSection
                resultSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                previewImage = image
            }
            .ignoresSafeArea()
        }
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

    @ViewBuilder
    private var photoSection: some View {
        Group {
            if let previewImage {
                Image(uiImage: previewImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 220)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                                .foregroundStyle(.secondary)
                            Text("No photo selected")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
            }
        }
        .accessibilityLabel(previewImage == nil ? "No photo selected" : "Selected photo preview")
    }

    private var photoActionsSection: some View {
        VStack(spacing: 12) {
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label("Choose Photo", systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(isLoading)

            Button {
                showCamera = true
            } label: {
                Label("Take Photo", systemImage: "camera")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(isLoading || !isCameraAvailable)

            if !isCameraAvailable {
                Text("Camera is not available on this device.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var analyzeSection: some View {
        Button {
            analyzePhoto()
        } label: {
            Label("Analyze Photo", systemImage: "sparkles")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isLoading || previewImage == nil)
    }

    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search by Name")
                .font(.headline)

            TextField("Place name", text: $placeName)
                .textFieldStyle(.roundedBorder)
                .disabled(isLoading)

            Button {
                askAI()
            } label: {
                Label("Ask AI", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isLoading || placeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    @ViewBuilder
    private var resultSection: some View {
        if isLoading {
            VStack(spacing: 12) {
                ProgressView()
                Text("Thinking...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else if let errorMessage {
            InfoCard(
                title: "Error",
                value: errorMessage,
                systemImage: "exclamationmark.triangle"
            )
        } else if let recognitionResult {
            VStack(alignment: .leading, spacing: 12) {
                Text("Results")
                    .font(.headline)

                PlaceRecognitionResultView(result: recognitionResult)
            }
        } else if textResponse != "AI response will appear here." {
            InfoCard(
                title: "Response",
                value: textResponse,
                systemImage: "text.bubble"
            )
        }
    }

    private func analyzePhoto() {
        guard let previewImage else { return }

        isLoading = true
        errorMessage = nil
        Task {
            do {
                recognitionResult = try await analyzePlace(image: previewImage)
            } catch {
                recognitionResult = nil
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func askAI() {
        let name = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        recognitionResult = nil
        Task {
            textResponse = await askGemini(place: name)
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        ExplorePlaceView()
    }
}
