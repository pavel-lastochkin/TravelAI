//
//  PhotoLocationReader.swift
//  Travel AI
//
//  Created by Pavel Lastochkin on 14.06.2026.
//

import Foundation
import ImageIO
import Photos
import PhotosUI
import SwiftUI

enum PhotoLocationReader {
    static func locationContext(from item: PhotosPickerItem, imageData: Data?) -> PhotoLocationContext? {
        if let assetLocation = locationFromPhotoAsset(item) {
            #if DEBUG
            print("Gallery location source: PHAsset metadata")
            #endif
            return assetLocation
        }

        if let imageData, let exifLocation = locationFromImageData(imageData) {
            #if DEBUG
            print("Gallery location source: image EXIF metadata")
            #endif
            return exifLocation
        }

        #if DEBUG
        print("Gallery location source: none")
        #endif
        return nil
    }

    private static func locationFromPhotoAsset(_ item: PhotosPickerItem) -> PhotoLocationContext? {
        guard let identifier = item.itemIdentifier else { return nil }

        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = assets.firstObject, let location = asset.location else { return nil }

        return PhotoLocationContext(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            source: .photoMetadata
        )
    }

    private static func locationFromImageData(_ data: Data) -> PhotoLocationContext? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let gps = properties[kCGImagePropertyGPSDictionary] as? [CFString: Any],
              let latitude = gps[kCGImagePropertyGPSLatitude] as? Double,
              let longitude = gps[kCGImagePropertyGPSLongitude] as? Double else {
            return nil
        }

        let latitudeRef = gps[kCGImagePropertyGPSLatitudeRef] as? String
        let longitudeRef = gps[kCGImagePropertyGPSLongitudeRef] as? String

        let signedLatitude = latitudeRef == "S" ? -latitude : latitude
        let signedLongitude = longitudeRef == "W" ? -longitude : longitude

        return PhotoLocationContext(
            latitude: signedLatitude,
            longitude: signedLongitude,
            source: .photoMetadata
        )
    }
}
