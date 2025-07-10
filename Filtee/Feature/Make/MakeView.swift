//
//  MakeView.swift
//  Filtee
//
//  Created by 김도형 on 5/30/25.
//

import SwiftUI
import PhotosUI
import ImageIO
import UniformTypeIdentifiers

struct MakeView: View {
    @Environment(\.filterClient.files)
    private var filterClientFiles
    @Environment(\.filterClient.filters)
    private var filterClientFilters
    
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
    @State
    private var nameState: FilteeTextFieldStyle.TextFieldState = .default
    @State
    private var descriptionState: FilteeTextFieldStyle.TextFieldState = .default
    @State
    private var priceState: FilteeTextFieldStyle.TextFieldState = .default
    @State
    private var imagePickerHeight: CGFloat = 0
    
    var body: some View {
        ScrollView(content: content)
            .filteeNavigation(
                title: "MAKE",
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
            .textFieldStyle(.filtee(nameState, title: "필터명"))
            .padding(.horizontal, 20)
            
            categorySection
            
            photoSection
            
            TextField(text: $filter.description) {
                Text("이 필터에 대해 간단하게 소개해주세요.")
            }
            .textFieldStyle(.filtee(descriptionState, title: "소개"))
            .padding(.horizontal, 20)
            
            TextField(text: .init(
                get: { filter.price.description },
                set: { filter.price = Int($0) ?? 0 }
            )) {
                Text("1000")
            }
            .keyboardType(.numberPad)
            .textFieldStyle(.filtee(
                priceState,
                title: "판매가격",
                subtitle: "원"
            ))
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.bottom, 68)
    }
    
    func trailingItems() -> some View {
        Button(action: saveButtonAction) {
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
            GeometryReader { proxy in
                let width = proxy.frame(in: .local).width
                
                PhotosPicker(selection: $pickerItem) { [imagePickerHeight] in
                    Image(uiImage: UIImage(cgImage: filteredImage))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: imagePickerHeight)
                }
                .frame(width: width, height: width)
                .onAppear { imagePickerHeight = width }
            }
            .frame(height: imagePickerHeight)
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
            .filteeBlurReplace()
        }
    }
}

// MARK: - Functions
private extension MakeView {
    func pickerItemOnChange(_ newValue: PhotosPickerItem?) {
        guard let newValue else { return }
        filter.photoMetadata = nil
        
        Task {
            do {
                // 에러 핸들링 개선
                guard let data = try await newValue.loadTransferable(type: Data.self) else {
                    print("이미지 데이터를 불러올 수 없습니다.")
                    return
                }
                
                guard let uiImage = UIImage(data: data) else {
                    print("이미지 형식이 지원되지 않습니다.")
                    return
                }
                
                guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
                    print("이미지 소스를 생성할 수 없습니다.")
                    return
                }
                
                guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
                    print("이미지 메타데이터를 읽을 수 없습니다.")
                    return
                }
                
                // 메타데이터 추출 (개선된 버전)
                let exifData = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any]
                let tiffData = metadata[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
                let gpsData = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any]
                
                // 카메라 정보 추출 개선
                let camera = tiffData?[kCGImagePropertyTIFFModel as String] as? String
                
                // 렌즈 정보 추출 개선
                let focalLength = exifData?[kCGImagePropertyExifFocalLength as String] as? Double
                let focalLength35mm = exifData?[kCGImagePropertyExifFocalLenIn35mmFilm as String] as? Double
                
                let lensInfo: String? = {
                    switch focalLength35mm ?? focalLength ?? 0 {
                    case ...24:
                        return "초광각 카메라"
                    case 25...35:
                        return "광각 카메라"
                    case 35...50:
                        return "표준 카메라"
                    case 51...:
                        return "망원 카메라"
                    default:
                        return nil
                    }
                }()
                
                // 조리개값 추출 개선
                let aperture = exifData?[kCGImagePropertyExifFNumber as String] as? Double
                
                // ISO 추출 개선
                let iso: Int? = {
                    if let isoArray = exifData?[kCGImagePropertyExifISOSpeedRatings as String] as? [Int],
                       let firstISO = isoArray.first {
                        return firstISO
                    }
                    return exifData?[kCGImagePropertyExifISOSpeed as String] as? Int
                }()
                
                // 셔터스피드 추출 개선
                let shutterSpeed: String? = {
                    if let exposureTime = exifData?[kCGImagePropertyExifExposureTime as String] as? Double {
                        if exposureTime >= 1 {
                            return String(format: "%.1fs", exposureTime)
                        } else {
                            let denominator = Int(round(1 / exposureTime))
                            return "1/\(denominator) sec"
                        }
                    }
                    return nil
                }()
                
                // 이미지 크기 정보
                let pixelHeight = metadata[kCGImagePropertyPixelHeight as String] as? Int
                let pixelWidth = metadata[kCGImagePropertyPixelWidth as String] as? Int
                let fileSize = data.count
                
                // 파일 포맷 감지 개선
                let format: String = {
                    if let typeIdentifier = CGImageSourceGetType(source) {
                        let typeString = typeIdentifier as String
                        switch typeString {
                        case UTType.jpeg.identifier:
                            return "JPEG"
                        case UTType.heic.identifier:
                            return "HEIC"
                        case UTType.png.identifier:
                            return "PNG"
                        case UTType.tiff.identifier:
                            return "TIFF"
                        default:
                            return typeString.components(separatedBy: ".").last?.uppercased() ?? "Unknown"
                        }
                    }
                    return "Unknown"
                }()
                
                // 날짜 정보
                let dateTimeOriginal = exifData?[kCGImagePropertyExifDateTimeOriginal as String] as? String
                
                // GPS 정보 추출 개선
                let (latitude, longitude): (Double?, Double?) = {
                    guard let lat = gpsData?[kCGImagePropertyGPSLatitude as String] as? Double,
                          let latRef = gpsData?[kCGImagePropertyGPSLatitudeRef as String] as? String,
                          let lon = gpsData?[kCGImagePropertyGPSLongitude as String] as? Double,
                          let lonRef = gpsData?[kCGImagePropertyGPSLongitudeRef as String] as? String
                    else { return (nil, nil) }
                    
                    let finalLat = latRef == "S" ? -lat : lat
                    let finalLon = lonRef == "W" ? -lon : lon
                    return (finalLat, finalLon)
                }()
                
                withAnimation(.filteeSpring) {
                    filteredImage = uiImage.cgImage
                    guard let cgImage = filteredImage else { return }
                    originalImage = UIImage(cgImage: cgImage)
                    filter.photoMetadata = PhotoMetadataModel(
                        camera: camera,
                        lensInfo: lensInfo,
                        focalLength: Float(focalLength35mm ?? focalLength ?? 0),
                        aperture: Float(aperture ?? 0),
                        iso: iso,
                        shutterSpeed: shutterSpeed,
                        pixelHeight: pixelHeight,
                        pixelWidth: pixelWidth,
                        fileSize: fileSize,
                        format: format,
                        dateTimeOriginal: dateTimeOriginal,
                        latitude: Float(latitude ?? 0),
                        longitude: Float(longitude ?? 0)
                    )
                }
                
            } catch {
                print("이미지 처리 중 오류가 발생했습니다: \(error.localizedDescription)")
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
    
    func saveButtonAction() {
        Task {
            do {
                guard !filter.title.filter(\.isLetter).isEmpty else {
                    nameState = .error("필터 제목을 공백 제외 한 글자 이상 입력해주세요.")
                    return
                }
                guard !filter.description.filter(\.isLetter).isEmpty else {
                    descriptionState = .error("필터 소개를 공백 제외 한 글자 이상 입력해주세요.")
                    return
                }
                guard let filteredImage,
                      let originalImage,
                      let filteredImageData = UIImage(cgImage: filteredImage).jpegData(
                        compressionQuality: 0.3
                      ),
                      let originalImageData = originalImage.jpegData(
                        compressionQuality: 0.3
                      )
                else { return }
                let files = try await filterClientFiles([
                    originalImageData,
                    filteredImageData
                ])
                filter.files = files
                try await filterClientFilters(filter)
                filter = FilterMakeModel()
                self.filteredImage = nil
                self.originalImage = nil
                self.pickerItem = nil
            } catch {
                print(error)
            }
        }
    }
    
    
}

#Preview {
    MakeView()
}
