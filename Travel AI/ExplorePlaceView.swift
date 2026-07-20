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

    @State private var selectedAction: PlaceExploreAction?
    @State private var placeDetails: PlaceDetailContent?
    @State private var isLoadingDetails = false
    @State private var detailsError: String?
    @State private var nearbyPlaces: NearbyPlacesResult?
    @State private var isLoadingNearby = false
    @State private var nearbyError: String?
    @State private var detailsRequestID = UUID()
    @State private var nearbyRequestID = UUID()

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
                    recognitionResult: recognitionResult,
                    selectedAction: $selectedAction,
                    placeDetails: placeDetails,
                    isLoadingDetails: isLoadingDetails,
                    detailsError: detailsError,
                    nearbyPlaces: nearbyPlaces,
                    isLoadingNearby: isLoadingNearby,
                    nearbyError: nearbyError,
                    onSelectAction: handleActionSelection
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
        detailsRequestID = UUID()
        nearbyRequestID = UUID()

        recognitionResult = nil
        errorMessage = nil
        selectedAction = nil
        placeDetails = nil
        isLoadingDetails = false
        detailsError = nil
        nearbyPlaces = nil
        isLoadingNearby = false
        nearbyError = nil
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
        clearAnalysisState()

        Task {
            #if DEBUG
            print("Selected image source: \(photoSource.map { String(describing: $0) } ?? "none")")
            print("Analysis location source: \(photoLocationContext.map { String(describing: $0.source) } ?? "none")")
            print("Analysis mode: \(photoLocationContext == nil ? "image-only" : "image + location")")
            #endif

            do {
                let result = try await analyzePlace(
                    image: previewImage,
                    location: photoLocationContext,
                    responseLanguage: appSettings.resolvedAIResponseLanguageName
                )
                recognitionResult = result
                prefetchPlaceDetails(for: result)
            } catch {
                recognitionResult = nil
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    private func handleActionSelection(_ action: PlaceExploreAction) {
        if selectedAction == action {
            selectedAction = nil
            return
        }

        selectedAction = action

        if action == .nearby {
            loadNearbyPlacesIfNeeded()
        }
    }

    private func prefetchPlaceDetails(for place: PlaceRecognitionResult) {
        let requestID = UUID()
        detailsRequestID = requestID
        isLoadingDetails = true
        detailsError = nil
        placeDetails = nil

        Task {
            do {
                let details = try await fetchPlaceDetails(
                    place: place,
                    responseLanguage: appSettings.resolvedAIResponseLanguageName
                )
                guard detailsRequestID == requestID else { return }
                placeDetails = details
                detailsError = nil
            } catch {
                guard detailsRequestID == requestID else { return }
                placeDetails = nil
                detailsError = error.localizedDescription
            }
            if detailsRequestID == requestID {
                isLoadingDetails = false
            }
        }
    }

    private func loadNearbyPlacesIfNeeded() {
        guard nearbyPlaces == nil, !isLoadingNearby else { return }
        guard let recognitionResult else { return }

        let requestID = UUID()
        nearbyRequestID = requestID
        isLoadingNearby = true
        nearbyError = nil

        Task {
            do {
                let nearby = try await fetchNearbyPlaces(
                    place: recognitionResult,
                    location: photoLocationContext,
                    responseLanguage: appSettings.resolvedAIResponseLanguageName
                )
                guard nearbyRequestID == requestID else { return }
                nearbyPlaces = nearby
                nearbyError = nil
            } catch {
                guard nearbyRequestID == requestID else { return }
                nearbyPlaces = nil
                nearbyError = error.localizedDescription
            }
            if nearbyRequestID == requestID {
                isLoadingNearby = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExplorePlaceView()
            .environmentObject(AppSettings())
    }
}
