//
//  ExplorePlaceView.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import PhotosUI
import SwiftUI

struct ExplorePlaceView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @StateObject private var locationManager = LocationManager()
    @State private var recognitionResult: PlaceRecognitionResult?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var previewImage: UIImage?
    @State private var showCamera = false
    @State private var showSettings = false
    @State private var photoSource: PhotoSource?
    @State private var photoLocationContext: PhotoLocationContext?

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    private var canIdentifyPlace: Bool {
        previewImage != nil && !isLoading
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                photoSection
                ExplorePhotoActionsView(
                    selectedPhoto: $selectedPhoto,
                    isLoading: isLoading,
                    isCameraAvailable: isCameraAvailable,
                    onCameraTap: { showCamera = true }
                )
                identifySection
                if let photoLocationContext {
                    PhotoLocationRowView(context: photoLocationContext)
                        .transition(.opacity)
                }
                ExploreResultSectionView(
                    isLoading: isLoading,
                    errorMessage: errorMessage,
                    recognitionResult: recognitionResult
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .animation(.easeInOut(duration: 0.28), value: previewImage != nil)
            .animation(.easeInOut(duration: 0.2), value: canIdentifyPlace)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .onAppear {
            locationManager.requestPermissionIfNeeded()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(appSettings)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                selectedPhoto = nil
                previewImage = image
                photoSource = .camera
                photoLocationContext = nil
                clearAnalysisState()

                Task {
                    let captureLocation = await locationManager.cameraCaptureContext()
                    photoLocationContext = captureLocation
                    #if DEBUG
                    print("Selected image source: camera")
                    print("Analysis location source: \(captureLocation.map { String(describing: $0.source) } ?? "none")")
                    #endif
                }
            }
            .ignoresSafeArea()
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                guard let newItem else { return }

                clearSelectedImageState()
                photoSource = .gallery

                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    previewImage = image
                    photoLocationContext = PhotoLocationReader.locationContext(from: newItem, imageData: data)
                    #if DEBUG
                    print("Selected image source: gallery")
                    print("Gallery metadata found: \(photoLocationContext != nil)")
                    print("Analysis location source: \(photoLocationContext.map { String(describing: $0.source) } ?? "none")")
                    #endif
                } else {
                    previewImage = nil
                    photoLocationContext = nil
                }
            }
        }
    }

    @ViewBuilder
    private var photoSection: some View {
        Group {
            if let previewImage {
                ExplorePhotoPreviewCard(image: previewImage)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                ExploreEmptyStateView()
                    .transition(.opacity)
            }
        }
    }

    private var identifySection: some View {
        VStack(spacing: 10) {
            Button {
                analyzePhoto()
            } label: {
                Label("Identify Place", systemImage: "location.viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canIdentifyPlace)
            .opacity(canIdentifyPlace ? 1 : 0.55)

            if let locationStatusText {
                Text(locationStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var locationStatusText: String? {
        guard let photoSource else { return nil }

        switch photoSource {
        case .gallery:
            if photoLocationContext != nil {
                return "Using photo location for better recognition"
            }
            return "Photo has no location data — analyzing image only"
        case .camera:
            if photoLocationContext != nil {
                return "Using camera location for better recognition"
            }
            return "Location unavailable — analyzing image only"
        }
    }

    private func clearAnalysisState() {
        recognitionResult = nil
        errorMessage = nil
    }

    private func clearSelectedImageState() {
        previewImage = nil
        photoLocationContext = nil
        photoSource = nil
        clearAnalysisState()
    }

    private func analyzePhoto() {
        guard let previewImage else { return }

        isLoading = true
        errorMessage = nil
        recognitionResult = nil

        Task {
            #if DEBUG
            print("Selected image source: \(photoSource.map { String(describing: $0) } ?? "none")")
            print("Analysis location source: \(photoLocationContext.map { String(describing: $0.source) } ?? "none")")
            print("Analysis mode: \(photoLocationContext == nil ? "image-only" : "image + location")")
            #endif

            do {
                recognitionResult = try await analyzePlace(
                    image: previewImage,
                    location: photoLocationContext,
                    responseLanguage: appSettings.resolvedAIResponseLanguageName
                )
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
            .environmentObject(AppSettings())
    }
}
