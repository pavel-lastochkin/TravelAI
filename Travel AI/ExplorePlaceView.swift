//
//  ExplorePlaceView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import PhotosUI
import SwiftUI

struct ExplorePlaceView: View {
    @StateObject private var locationManager = LocationManager()
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
            VStack(spacing: 20) {
                photoSection
                photoActionsSection
                analyzeSection
                resultSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            locationManager.requestPermissionIfNeeded()
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                previewImage = image
                clearAnalysisState()
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                guard let newItem else {
                    previewImage = nil
                    clearAnalysisState()
                    return
                }
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    previewImage = image
                    clearAnalysisState()
                } else {
                    previewImage = nil
                    clearAnalysisState()
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
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
                    .frame(height: 240)
                    .overlay {
                        VStack(spacing: 10) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                            Text("Add a photo to identify a landmark")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 24)
                    }
            }
        }
        .accessibilityLabel(previewImage == nil ? "No photo selected" : "Selected photo preview")
    }

    private var photoActionsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("Gallery", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(isLoading)

                Button {
                    showCamera = true
                } label: {
                    Label("Camera", systemImage: "camera")
                        .frame(maxWidth: .infinity)
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

    private var analyzeSection: some View {
        VStack(spacing: 8) {
            Button {
                analyzePhoto()
            } label: {
                Label("Analyze Photo", systemImage: "sparkles")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isLoading || previewImage == nil)

            Text(locationManager.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var resultSection: some View {
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
        } else if let recognitionResult {
            ResultCardView(result: recognitionResult)
        }
    }

    private func clearAnalysisState() {
        recognitionResult = nil
        errorMessage = nil
    }

    private func analyzePhoto() {
        guard let previewImage else { return }

        isLoading = true
        errorMessage = nil
        recognitionResult = nil

        Task {
            let coordinate = await locationManager.currentCoordinateForAnalysis()
            do {
                recognitionResult = try await analyzePlace(image: previewImage, coordinate: coordinate)
            } catch {
                recognitionResult = nil
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        ExplorePlaceView()
    }
}
