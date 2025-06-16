//
//  FilteeMetadataCell.swift
//  Filtee
//
//  Created by 김도형 on 6/10/25.
//

import SwiftUI
import MapKit
import Contacts

struct FilteeMetadataCell: View {
    @State
    private var photoAddress: String?
    
    private let photoMetadata: PhotoMetadataModel
    
    init(photoMetadata: PhotoMetadataModel) {
        self.photoMetadata = photoMetadata
    }
    
    var body: some View {
        FilteeContentCell(
            title: photoMetadata.camera ?? "정보없음",
            subtitle: "EXIF"
        ) {
            HStack(spacing: 16) {
                miniMap
                
                metadata
                
                Spacer()
            }
            .padding(8)
        }
        .task(bodyTask)
        .onChange(
            of: photoMetadata,
            perform: photoMetadataOnChange
        )
    }
    
    @ViewBuilder
    private var miniMap: some View {
        if let latitude = photoMetadata.latitude,
           let longitude = photoMetadata.longitude {
            let center = CLLocationCoordinate2D(
                latitude: Double(latitude),
                longitude: Double(longitude)
            )
            let region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 1000,
                longitudinalMeters: 100
            )
            
            Group {
                if #available(iOS 17.0, *) {
                    Map(initialPosition: .region(region))
                } else {
                    Map(coordinateRegion: .constant(region))
                }
            }
            .frame(width: 76, height: 76)
            .clipRectangle(8)
        }
    }
    
    @ViewBuilder
    private var metadata: some View {
        let lensInfo = photoMetadata.lensInfo ?? ""
        let focalLength = String(
            format: "%.2f",
            photoMetadata.focalLength ?? 0
        )
        let aperture = String(
            format: "%.1f",
            photoMetadata.aperture ?? 0
        )
        let iso = photoMetadata.iso?.description ?? ""
        let fileSize = ((photoMetadata.fileSize ?? 0) / (1024 * 1024))
        let pixelWidth = photoMetadata.pixelWidth ?? 0
        let pixelHeight = photoMetadata.pixelHeight ?? 0
        
        VStack(alignment: .leading, spacing: 8) {
            Text("\(lensInfo) - \(focalLength) mm 𝒇 \(aperture) ISO \(iso)")
            
            Text("\((pixelWidth * pixelHeight) / 1000 / 1000)MP • \(pixelWidth) × \(pixelHeight) • \(fileSize)MB")
            
            if let photoAddress = photoAddress {
                Text(photoAddress)
            }
        }
        .font(.pretendard(.caption1(.semiBold)))
        .foregroundStyle(.gray75)
    }
    
    @Sendable
    func bodyTask() async {
        self.photoAddress = await reverseGeocoder(
            latitude: photoMetadata.latitude,
            longitude: photoMetadata.longitude
        )
    }
    
    func photoMetadataOnChange(_ newValue: PhotoMetadataModel) {
        Task {
            self.photoAddress = await reverseGeocoder(
                latitude: newValue.latitude,
                longitude: newValue.longitude
            )
        }
    }
    
    private func reverseGeocoder(latitude: Float?, longitude: Float?) async -> String? {
        do {
            guard let latitude, let longitude else { return nil }
            let location = CLLocation(
                latitude: Double(latitude),
                longitude: Double(longitude)
            )
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let address = placemarks.first?.postalAddress else {
                return nil
            }
            return address.city + " " + address.street
        } catch {
            print(error)
            return nil
        }
    }
}

