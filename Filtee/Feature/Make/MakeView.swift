//
//  MakeView.swift
//  Filtee
//
//  Created by 김도형 on 5/30/25.
//

import SwiftUI
import PhotosUI
import ImageIO

struct MakeView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<MakePath>
    
    @State
    private var filter = FilterMakeModel()
    @State
    private var pickerItem: PhotosPickerItem?
    @State
    private var filteredImage: CGImage?
    @State
    private var originalImage: UIImage?
    
    var body: some View {
        ScrollView(content: content)
            .filteeNavigation(
                title: "MAKE",
                leadingItems: leadingItems,
                trailingItems: trailingItems
            )
            .background(content: scrollViewBackground)
            .onChange(of: pickerItem, perform: pickerItemOnChange)
    }
}

// MARK: - Configure Views
private extension MakeView {
    func content() -> some View {
        VStack(spacing: 12) {
            TextField(text: $filter.title) {
                Text("필터 이름을 입력해주세요.")
            }
            .textFieldStyle(.filtee(.default, title: "필터명"))
            .padding(.horizontal, 20)
            
            categorySection
            
            photoSection
            
            TextField(text: $filter.description) {
                Text("이 필터에 대해 간단하게 소개해주세요.")
            }
            .textFieldStyle(.filtee(.default, title: "소개"))
            .padding(.horizontal, 20)
            
            TextField(text: $filter.description) {
                Text("1000")
            }
            .keyboardType(.numberPad)
            .textFieldStyle(.filtee(
                .default,
                title: "판매가격",
                subtitle: "원"
            ))
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.bottom, 68)
    }
    
    func leadingItems() -> some View {
        Button(action: { }) {
            Image(.chevron)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    func trailingItems() -> some View {
        Button(action: {}) {
            Image(.save)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    func backgroundImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .overlay(Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.9))
            .ignoresSafeArea()
    }
    
    func scrollViewBackground() -> some View {
        VisualEffect(style: .systemChromeMaterialDark)
            .ifLet(originalImage) { view, image in
                view.background { backgroundImage(image) }
            }
            .ignoresSafeArea()
    }
    
    func section(
        _ title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(spacing: 0) {
            FilteeTitle(title)
            
            content()
        }
    }
    
    @ViewBuilder
    var categorySection: some View {
        let categories = FilterMakeModel.Category.allCases
        
        section("카테고리") {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        let isSelectd = filter.category == category.rawValue
                        Button(category.rawValue) {
                            categoryButtonAction(category.rawValue)
                        }
                        .buttonStyle(.filteeSelected(isSelectd))
                        .animation(.filteeDefault, value: isSelectd)
                        .padding(.vertical, 1)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    var photoSection: some View {
        VStack(spacing: 0) {
            FilteeTitle("대표 사진 선택") {
                if filteredImage != nil {
                    Button("수정하기") {
                        editButtonAction()
                    }
                    .font(.pretendard(.body1(.medium)))
                    .foregroundStyle(.gray75)
                }
            }
            
            photoPicker
            
            if let photoMetadata =  filter.photoMetadata {
                FilteeMetadataCell(photoMetadata: photoMetadata)
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    .filteeBlurReplace()
            }
        }
    }
    
    @ViewBuilder
    var photoPicker: some View {
        if let filteredImage {
            PhotosPicker(selection: $pickerItem) {
                Image(uiImage: UIImage(cgImage: filteredImage))
                    .resizable()
            }
            .aspectRatio(1, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipRectangle(12)
            .clipped()
            .padding(.horizontal, 20)
            .filteeBlurReplace()
        } else {
            PhotosPicker(selection: $pickerItem) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.blackTurquoise)
                    .overlay {
                        Image(.plus)
                            .resizable()
                            .foregroundStyle(.gray75)
                            .frame(width: 32, height: 32)
                    }
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Functions
private extension MakeView {
    func pickerItemOnChange(_ newValue: PhotosPickerItem?) {
        guard let newValue else { return }
        filter.photoMetadata = nil
        Task {
            guard
                let data = try? await newValue.loadTransferable(type: Data.self),
                let uiImage = UIImage(data: data),
                let source = CGImageSourceCreateWithData(data as CFData, nil),
                let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any]
            else { return }
            
            withAnimation(.filteeSpring) {
            }
            
            let exifData = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any]
            let tiffData = metadata[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
            let gpsData = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any]
            
            let camera = exifData?[kCGImagePropertyTIFFModel as String] as? String ?? tiffData?[kCGImagePropertyTIFFModel as String] as? String
            let focalLength = exifData?[kCGImagePropertyExifFocalLength as String] as? Double
            let lensInfo: String?
            switch focalLength ?? -1 {
            case ..<20:
                lensInfo = "초광각 카메라"
            case 20..<35:
                lensInfo = "광각 카메라"
            case 35..<85:
                lensInfo = "표준 카메라"
            case 85...:
                lensInfo = "망원 카메라"
            default:
                lensInfo = nil
            }
            let aperture = exifData?[kCGImagePropertyExifApertureValue as String] as? Double
            let iso = (exifData?[kCGImagePropertyExifISOSpeedRatings as String] as? [Int])?.first
            let shutterSpeed = (exifData?[kCGImagePropertyExifExposureTime as String] as? Double).map {
                let denominator = Int(1 / $0)
                return "1/\(denominator)"
            }
            let pixelHeight = metadata[kCGImagePropertyPixelHeight as String] as? Int
            let pixelWidth = metadata[kCGImagePropertyPixelWidth as String] as? Int
            let fileSize = data.count
            let format = metadata[kCGImagePropertyFileContentsDictionary as String] as? String
            let dateTimeOriginal = exifData?[kCGImagePropertyExifDateTimeOriginal as String] as? String
            let latitude = gpsData?[kCGImagePropertyGPSLatitude as String] as? Double
            let longitude = gpsData?[kCGImagePropertyGPSLongitude as String] as? Double
            
            let orientationValue = metadata[kCGImagePropertyOrientation as String] as? UInt32
            let orientation = CGImagePropertyOrientation(rawValue: orientationValue ?? 1)
            
            withAnimation(.filteeSpring) {
                filteredImage = uiImage.cgImage?.oriented(orientation ?? .up)
                guard let cgImage = filteredImage else { return }
                originalImage = UIImage(cgImage: cgImage)
                filter.photoMetadata = PhotoMetadataModel(
                    camera: camera,
                    lensInfo: lensInfo,
                    focalLength: focalLength,
                    aperture: aperture,
                    iso: iso,
                    shutterSpeed: shutterSpeed,
                    pixelHeight: pixelHeight,
                    pixelWidth: pixelWidth,
                    fileSize: fileSize,
                    format: format,
                    dateTimeOriginal: dateTimeOriginal,
                    latitude: latitude,
                    longitude: longitude
                )
            }
        }
    }
    
    func categoryButtonAction(_ category: String) {
        filter.category = category
    }
    
    func editButtonAction() {
        navigation.push(.edit(
            filteredImage: $filteredImage,
            originalImage: $originalImage,
            filterValues: $filter.filterValues
        ))
    }
}

#Preview {
    MakeView()
}
