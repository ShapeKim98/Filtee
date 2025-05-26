//
//  FilterDetailView.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import SwiftUI
import MapKit

import Nuke

struct FilterDetailView: View {
    @Environment(\.filterClient.filterDetail)
    private var filterClientFilterDetail
    
    @State
    private var filter: FilterDetailModel?
    @State
    private var originalImage: Image?
    @State
    private var filteredImage: Image? = Image(.sampleFiltered)
    @State
    private var filterPivot: CGFloat = 0
    @State
    private var imageSectionHeight: CGFloat = 0
    
    private let filterId: String
    
    init(filterId: String) {
        self.filterId = filterId
    }
    
    var body: some View {
        ScrollView(content: content)
            .background {
                scrollViewBackground
            }
            .task(bodyTask)
    }
}

// MARK: - Configure Views
private extension FilterDetailView {
    func content() -> some View {
        VStack(spacing: 28) {
            imageSection
            
            price
            
            informationSection
        }
    }
    
    func backgroundImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .overlay(.gray100.opacity(0.95))
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
            
            //            if let originalImage, let filteredImage {
            Image(.sampleOriginal)
                .squareImage(width)
            //                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 0, z: 1))
                .frame(width: filterPivot, alignment: .leading)
                .cornerRadius(radius: 24, corners: [.topLeft, .bottomLeft])
                .clipped()
                .offset(x: local.minX)
            
            Image(.sampleFiltered)
                .squareImage(width)
                .frame(width: width - filterPivot, alignment: .trailing)
                .cornerRadius(radius: 24, corners: [.topRight, .bottomRight])
                .clipped()
                .offset(x: local.minX + filterPivot)
            //            }
            
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
        .background(.blackTurquoise)
        .clipRectangle(8)
    }
    
    var informationSection: some View {
        VStack(spacing: 20) {
            countSection
            
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
        .padding(.horizontal, 20)
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
            
        }
        .font(.pretendard(.caption1(.semiBold)))
        .foregroundStyle(.gray75)
    }
}

// MARK: - Functions
private extension FilterDetailView {
    @Sendable
    func bodyTask() async {
        do {
            filter = try await filterClientFilterDetail(filterId)
            guard
                let original = filter?.original,
                let filtered = filter?.filtered,
                let originalURL = URL(string: original),
                let filteredURL = URL(string: filtered)
            else { return }
            
//            async let originalUIImage = ImagePipeline.shared.imageTask(
//                with: originalURL
//            ).response.image
//            async let filteredUIImage = ImagePipeline.shared.imageTask(
//                with: filteredURL
//            ).response.image
//            
//            originalImage = Image(uiImage: try await originalUIImage)
//            filteredImage = Image(uiImage: try await filteredUIImage)
        } catch {
            print(error)
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
