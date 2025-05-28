//
//  FilterDetailView.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import SwiftUI
import MapKit
import Contacts

import Nuke

struct FilterDetailView: View {
    @Environment(\.mainNavigation)
    private var navigation
    
    @Environment(\.filterClient.filterDetail)
    private var filterClientFilterDetail
    @Environment(\.filterClient.filterLike)
    private var filterClientFilterLike
    
    @State
    private var filter: FilterDetailModel?
    @State
    private var originalImage: Image? = Image(.sampleOriginal)
    @State
    private var filteredImage: Image? = Image(.sampleFiltered)
    @State
    private var filterPivot: CGFloat = 0
    @State
    private var imageSectionHeight: CGFloat = 0
    @State
    private var photoAddress: String?
    
    private let filterId: String
    
    init(filterId: String) {
        self.filterId = filterId
    }
    
    var body: some View {
        ScrollView(content: content)
            .filteeNavigation(
                title: filter?.title ?? "",
                leadingItems: toolbarLeading,
                trailingItems: toolbarTrailing
            )
            .background {
                scrollViewBackground
            }
            .task(bodyTask)
    }
}

// MARK: - Configure Views
private extension FilterDetailView {
    func toolbarLeading() -> some View {
        Button(action: backButtonAction) {
            Image(.chevron).resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    @ViewBuilder
    func toolbarTrailing() -> some View {
        let isLike = filter?.isLike ?? false
        let image: ImageResource = isLike ? .likeFill : .likeEmpty
        
        Button(action: likeButtonAction) {
            Image(image).resizable()
        }
        .buttonStyle(.filteeToolbar)
        .animation(.filteeDefault, value: isLike)
    }
    
    func content() -> some View {
        VStack(spacing: 28) {
            imageSection
            
            price
            
            informationSection
            
            if let creator = filter?.creator {
                FilteeProfile(profile: creator)
            }
        }
    }
    
    func backgroundImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .overlay(Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.9))
            .ignoresSafeArea()
    }
    
    var scrollViewBackground: some View {
        VisualEffect(style: .systemChromeMaterialDark)
            .ifLet(filteredImage) { view, image in
                view.background { backgroundImage(image) }
            }
            .ignoresSafeArea()
    }
    
    var imageSection: some View {
        GeometryReader { proxy in
            let local = proxy.frame(in: .local)
            let width = local.width
            
            if let originalImage, let filteredImage {
                originalImage
                    .squareImage(width)
//                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                    .frame(width: filterPivot, alignment: .leading)
                    .cornerRadius(radius: 24, corners: [.topLeft, .bottomLeft])
                    .clipped()
                    .offset(x: local.minX)
                
                filteredImage
                    .squareImage(width)
                    .frame(width: width - filterPivot, alignment: .trailing)
                    .cornerRadius(radius: 24, corners: [.topRight, .bottomRight])
                    .clipped()
                    .offset(x: local.minX + filterPivot)
            }
            
            let sliderWidth: CGFloat = 48 * 2 + 8 + 24
            
            filterSlider
                .offset(x: filterPivot - sliderWidth / 2, y: width + 12)
                .gesture(DragGesture().onChanged({ value in
                    filterSliderDragGestureOnChanged(value, in: local)
                }))
                .onAppear { filterSliderOnAppear(width) }
            
            divider
                .offset(y: width + 12 + 24 + 20)
        }
        .frame(height: imageSectionHeight)
        .padding(.horizontal, 20)
    }
    
    var filterSlider: some View {
        HStack(spacing: 4) {
            Text("After")
                .font(.pretendard(.caption2(.semiBold)))
                .foregroundStyle(.gray60)
                .frame(width: 48, height: 20)
                .background(.gray75.opacity(0.5))
                .clipRectangle(9999)
            
            Circle().fill(.gray75.opacity(0.5))
                .frame(width: 24, height: 24)
                .overlay {
                    Circle().stroke(.secondary, lineWidth: 2)
                }
                .overlay {
                    Image(.polygon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12, alignment: .top)
                        .foregroundStyle(.secondary)
                        .padding(6)
                }
            
            Text("Before")
                .font(.pretendard(.caption2(.semiBold)))
                .foregroundStyle(.gray60)
                .frame(width: 48, height: 20)
                .background(.gray75.opacity(0.5))
                .clipRectangle(9999)
        }
    }
    
    var divider: some View {
        Rectangle().fill(.deepTurquoise)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
    
    @ViewBuilder
    var price: some View {
        if let filter {
            HStack(alignment: .bottom, spacing: 8) {
                Text("\(filter.price)")
                    .font(.mulgyeol(.title1))
                    .foregroundStyle(.gray30)
                
                Text("Coin")
                    .font(.mulgyeol(.body1))
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    var countSection: some View {
        if let filter {
            HStack(spacing: 8) {
                countCell(title: "다운로드", count: filter.buyerCount)
                
                countCell(title: "찜하기", count: filter.likeCount)
                
                Spacer()
            }
        }
    }
    
    func countCell(title: String, count: Int) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.pretendard(.caption1(.semiBold)))
                .foregroundStyle(.gray75)
            
            Text("\(count)")
                .font(.pretendard(.title(.bold)))
                .foregroundStyle(.gray30)
        }
        .frame(width: 99, height: 56)
        .background(.deepTurquoise)
        .clipRectangle(8)
    }
    
    var informationSection: some View {
        VStack(spacing: 20) {
            countSection
            
            photoMetadata
            
            filterPresets
            
            let isDownloaded = filter?.isDownloaded ?? false
            Button(isDownloaded ? "구매완료" : "결제하기") {
                
            }
            .buttonStyle(.filteeCTA)
            .disabled(isDownloaded)
            
            divider
        }
        .padding(.horizontal, 20)
    }
    
    var photoMetadata: some View {
        FilteeContentCell(
            title: filter?.photoMetadata?.camera ?? "정보없음",
            subtitle: "EXIF"
        ) {
            HStack(spacing: 16) {
                miniMap
                
                metadata
                
                Spacer()
            }
            .padding(8)
        }
    }
    
    @ViewBuilder
    var miniMap: some View {
        if let latitude = filter?.photoMetadata?.latitude,
           let longitude = filter?.photoMetadata?.longitude {
            let center = CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
            let region = MKCoordinateRegion(
                center: center,
                latitudinalMeters: 76,
                longitudinalMeters: 76
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
    var metadata: some View {
        let lensInfo = filter?.photoMetadata?.lensInfo ?? ""
        let focalLength = filter?.photoMetadata?.focalLength?.description ?? ""
        let aperture = filter?.photoMetadata?.aperture?.description ?? ""
        let iso = filter?.photoMetadata?.iso?.description ?? ""
        let fileSize = ((filter?.photoMetadata?.fileSize ?? 0) / (1024 * 1024))
        let pixelWidth = filter?.photoMetadata?.pixelWidth ?? 0
        let pixelHeight = filter?.photoMetadata?.pixelHeight ?? 0
        
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
    
    @ViewBuilder
    var filterPresets: some View {
        if let presets = filter?.filterValues {
            FilteeContentCell(title: "Filter Presets", subtitle: "LUT") {
                VStack(spacing: 16) {
                    HStack {
                        filterValue(.brightness, value: presets.brightness)
                        
                        filterValue(.exposure, value: presets.exposure)
                        
                        filterValue(.contrast, value: presets.contrast)
                        
                        filterValue(.saturation, value: presets.saturation)
                        
                        filterValue(.sharpness, value: presets.sharpness)
                        
                        filterValue(.blur, value: presets.blur)
                    }
                    
                    HStack {
                        filterValue(.vignette, value: presets.vignette)
                        
                        filterValue(.noise, value: presets.noiseReduction)
                        
                        filterValue(.highlights, value: presets.highlights)
                        
                        filterValue(.shadows, value: presets.shadows)
                        
                        filterValue(.temperature, value: presets.temperature)
                        
                        filterValue(.blackPoint, value: presets.blackPoint)
                    }
                }
                .padding(20)
                .if(!(filter?.isDownloaded ?? false)) { $0.overlay {
                    ZStack {
                        VisualEffect(style: .systemUltraThinMaterial)
                        
                        VStack(spacing: 12) {
                            Image(.lock)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                            
                            Text("결제가 필요한 유료 필터입니다")
                                .font(.pretendard(.body1(.bold)))
                            
                        }
                        .foregroundStyle(.gray45)
                    }
                }}
            }
        }
    }
    
    func filterValue(
        _ resource: ImageResource,
        value: Double
    ) -> some View {
        VStack(spacing: 4) {
            Image(resource)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundStyle(.gray30)
            
            Text(String(format: "%.1f", value))
                .font(.pretendard(.body1(.bold)))
                .foregroundStyle(.gray75)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Functions
private extension FilterDetailView {
    @Sendable
    func bodyTask() async {
        do {
            filter = try await filterClientFilterDetail(filterId)
            filter?.creator.introduction = nil
            filter?.creator.description = filter?.description
            async let originalImage = fetchImage(urlString: filter?.original)
            async let filteredImage = fetchImage(urlString: filter?.filtered)
            async let address = reverseGeocoder(
                latitude: filter?.photoMetadata?.latitude,
                longitude: filter?.photoMetadata?.longitude
            )
            
            self.photoAddress = await address
//            self.originalImage = try await originalImage
//            self.filteredImage = try await filteredImage
        } catch {
            print(error)
        }
    }
    
    func fetchImage(urlString: String?) async throws -> Image? {
        guard let urlString, let url = URL(string: urlString) else {
            return nil
        }
        let image = try await ImagePipeline.shared.imageTask(with: url).response.image
        return Image(uiImage: image)
    }
    
    func reverseGeocoder(latitude: Double?, longitude: Double?) async -> String? {
        do {
            guard let latitude, let longitude else { return nil }
            let location = CLLocation(
                latitude: latitude,
                longitude: longitude
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
    
    func filterSliderDragGestureOnChanged(
        _ value: DragGesture.Value,
        in local: CGRect
    ) {
        guard
            0 <= value.location.x && value.location.x <= local.maxX
        else { return }
        
        filterPivot = value.location.x
    }
    
    func filterSliderOnAppear(_ width: CGFloat) {
        withAnimation(.spring) {
            filterPivot = width / 2
        }
        
        imageSectionHeight = width + 12 + 24 + 20 + 1
    }
    
    func likeButtonAction() {
        Task {
            guard let isLike = filter?.isLike else { return }
            do {
                self.filter?.isLike = try await filterClientFilterLike(filterId, !isLike)
            } catch {
                print(error)
            }
        }
    }
    
    func backButtonAction() {
        Task { await navigation.pop() }
    }
}

private extension Image {
    @MainActor
    func squareImage(_ width: CGFloat) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: width)
            .clipRectangle(24)
    }
}

#if DEBUG
#Preview {
    FilterDetailView(filterId: "")
        .environment(\.filterClient, .testValue)
}
#endif
